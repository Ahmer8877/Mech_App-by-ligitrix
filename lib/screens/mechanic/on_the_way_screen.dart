import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../cores/providers/auth_provider.dart';
import '../../cores/providers/bookings_provider.dart';
import '../../cores/providers/live_location_provider.dart';
import '../../cores/repositories/live_location_repository.dart';
import '../../cores/theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/live_google_map.dart';
import '../call/call_screen.dart';
import '../customer/chat_screen.dart';
import 'job_completed_screen.dart';

class OnTheWayScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const OnTheWayScreen({super.key, required this.bookingId});

  @override
  ConsumerState<OnTheWayScreen> createState() => _OnTheWayScreenState();
}

class _OnTheWayScreenState extends ConsumerState<OnTheWayScreen> {
  StreamSubscription<Position>? _positionSubscription;
  LiveLocation? _myLocation;
  bool _starting = true;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  Future<void> _startLocationTracking() async {
    final mechanicId = ref.read(authProvider).user?.id;
    if (mechanicId == null) {
      if (mounted) setState(() => _starting = false);
      return;
    }

    try {
      final permission = await _ensureLocationPermission();
      if (!permission) {
        if (mounted) {
          setState(() {
            _locationError = 'Please allow location permission and turn on GPS.';
            _starting = false;
          });
        }
        return;
      }

      // The moment the mechanic starts navigation, mark the job as on the way.
      await ref.read(bookingRepositoryProvider).updateStatus(widget.bookingId, 'on_the_way');

      final repository = ref.read(liveLocationRepositoryProvider);
      final firstPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await repository.updateMechanicLocation(
        bookingId: widget.bookingId,
        mechanicId: mechanicId,
        position: firstPosition,
      );
      _setMyLocation(mechanicId, firstPosition);

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((position) async {
        try {
          await repository.updateMechanicLocation(
            bookingId: widget.bookingId,
            mechanicId: mechanicId,
            position: position,
          );
          _setMyLocation(mechanicId, position);
        } catch (e) {
          if (mounted) setState(() => _locationError = 'GPS update failed: $e');
        }
      });
    } catch (e) {
      if (mounted) setState(() => _locationError = 'Unable to start live location: $e');
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<bool> _ensureLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  void _setMyLocation(String mechanicId, Position position) {
    if (!mounted) return;
    setState(() {
      _myLocation = LiveLocation(
        bookingId: widget.bookingId,
        mechanicId: mechanicId,
        latitude: position.latitude,
        longitude: position.longitude,
        heading: position.heading.isFinite ? position.heading : 0,
        updatedAt: DateTime.now(),
      );
    });
  }

  LatLng? _customerLocation(Map<String, dynamic>? booking) {
    final lat = (booking?['latitude'] as num?)?.toDouble();
    final lng = (booking?['longitude'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  Future<void> _complete() async {
    try {
      await ref.read(bookingRepositoryProvider).complete(widget.bookingId);
      await ref.read(liveLocationRepositoryProvider).clearMechanicLocation(widget.bookingId);
      ref.invalidate(mechanicBookingsProvider);
      ref.invalidate(bookingDetailsProvider(widget.bookingId));
      await _positionSubscription?.cancel();
      _positionSubscription = null;

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => JobCompletedScreen(bookingId: widget.bookingId)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Job complete nahi hua: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(bookingDetailsProvider(widget.bookingId));

    return Scaffold(
      appBar: AppBar(title: const Text('On The Way')),
      body: bookingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (booking) {
          final customer = booking?['customer'] as Map?;
          final name = customer?['full_name']?.toString() ?? 'Customer';
          final customerId = customer?['id']?.toString() ?? '';
          final initials = name
              .split(' ')
              .where((x) => x.isNotEmpty)
              .take(2)
              .map((x) => x[0])
              .join()
              .toUpperCase();

          return Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Expanded(
                  child: LiveGoogleMap(
                    customerLocation: _customerLocation(booking),
                    mechanicLocation: _myLocation,
                  ),
                ),
                if (_starting)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Starting live GPS tracking...'),
                  )
                else if (_locationError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _locationError!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: context.colors.textMuted, fontSize: 11),
                    ),
                  ),
                Text(
                  booking?['pickup_address']?.toString() ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlineActionButton(
                        label: 'Call Customer',
                        onPressed: customerId.isEmpty
                            ? null
                            : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CallScreen(name: name, initials: initials),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlineActionButton(
                        label: 'Chat',
                        onPressed: customerId.isEmpty
                            ? null
                            : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              bookingId: widget.bookingId,
                              otherUserId: customerId,
                              otherName: name,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AccentButton(
                  label: 'Mark Job Completed',
                  onPressed: _complete,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
