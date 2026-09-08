import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../cores/providers/bookings_provider.dart';
import '../../cores/providers/auth_provider.dart';
import '../../cores/providers/live_location_provider.dart';
import '../../cores/theme/app_theme.dart';
import '../../widgets/app_atoms.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/live_google_map.dart';
import '../call/call_screen.dart';
import 'chat_screen.dart';
import 'customer_home_screen.dart';
import 'payment_rating_screen.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const TrackingScreen({super.key, required this.bookingId});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  StreamSubscription<Position>? _positionSubscription;
  bool _locationStarted = false;

  Future<void> _startCustomerTracking() async {
    if (_locationStarted) return;
    _locationStarted = true;
    final customerId = ref.read(authProvider).user?.id;
    if (customerId == null) return;
    final permission = await _ensureLocationPermission();
    if (!permission) return;
    final repo = ref.read(liveLocationRepositoryProvider);
    try {
      final first = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await repo.updateCustomerLocation(
        bookingId: widget.bookingId,
        customerId: customerId,
        position: first,
      );
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).listen((position) async {
            try {
              await repo.updateCustomerLocation(
                bookingId: widget.bookingId,
                customerId: customerId,
                position: position,
              );
            } catch (_) {}
          });
    } catch (_) {}
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

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(bookingRepositoryProvider).cancel(widget.bookingId);
      ref.invalidate(bookingsProvider);
      ref.invalidate(bookingDetailsProvider(widget.bookingId));

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Booking cancel nahi hui: $e')));
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
    final ref = this.ref;
    final booking = ref.watch(bookingDetailsProvider(widget.bookingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Status')),
      body: booking.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (data) {
          if (data == null) {
            return const Center(child: Text('Booking not found'));
          }

          final mechanic = data['mechanic'];
          final mechanicMap = mechanic is Map ? mechanic : null;
          final name = mechanicMap?['full_name']?.toString() ?? 'Mechanic';
          final mechanicId = mechanicMap?['id']?.toString() ?? '';
          final initials = name
              .split(' ')
              .where((part) => part.isNotEmpty)
              .take(2)
              .map((part) => part[0])
              .join()
              .toUpperCase();
          final status = data['status']?.toString() ?? 'pending';
          if (status == 'accepted' ||
              status == 'on_the_way' ||
              status == 'in_progress') {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _startCustomerTracking(),
            );
          }
          final service = data['service_title']?.toString() ?? 'Service';
          final address = data['pickup_address']?.toString() ?? '';
          final lat = (data['latitude'] as num?)?.toDouble();
          final lng = (data['longitude'] as num?)?.toDouble();
          final live = ref
              .watch(bookingLiveLocationProvider(widget.bookingId))
              .valueOrNull;
          final customerLocation = live?.hasCustomerLocation == true
              ? LatLng(live!.customerLatitude!, live.customerLongitude!)
              : ((lat != null && lng != null) ? LatLng(lat, lng) : null);
          final mechanicLocation = live?.hasMechanicLocation == true
              ? live
              : null;

          return Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Expanded(
                  child: LiveGoogleMap(
                    customerLocation: customerLocation,
                    mechanicLocation: mechanicLocation,
                  ),
                ),
                AppCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: Text(initials.isEmpty ? 'M' : initials),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$service · $status',
                              style: TextStyle(
                                fontSize: 10,
                                color: context.colors.textMuted,
                              ),
                            ),
                            if (address.isNotEmpty)
                              Text(
                                address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: context.colors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlineActionButton(
                        label: 'Call',
                        onPressed: mechanicId.isEmpty
                            ? null
                            : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CallScreen(
                                    name: name,
                                    initials: initials,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlineActionButton(
                        label: 'Chat',
                        onPressed: mechanicId.isEmpty
                            ? null
                            : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    bookingId: widget.bookingId,
                                    otherUserId: mechanicId,
                                    otherName: name,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (status == 'completed')
                  AccentButton(
                    label: 'Payment & Rating',
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PaymentRatingScreen(bookingId: widget.bookingId),
                      ),
                    ),
                  )
                else if (status != 'cancelled')
                  OutlineActionButton(
                    label: 'Cancel Booking',
                    isDanger: true,
                    onPressed: () => _cancel(context, ref),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
