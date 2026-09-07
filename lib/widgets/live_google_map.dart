import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../cores/repositories/live_location_repository.dart';
import '../cores/theme/app_theme.dart';

class LiveGoogleMap extends StatefulWidget {
  final LatLng? customerLocation;
  final LiveLocation? mechanicLocation;
  final bool showCustomerMarker;
  final bool showMechanicMarker;

  const LiveGoogleMap({
    super.key,
    this.customerLocation,
    this.mechanicLocation,
    this.showCustomerMarker = true,
    this.showMechanicMarker = true,
  });

  @override
  State<LiveGoogleMap> createState() => _LiveGoogleMapState();
}

class _LiveGoogleMapState extends State<LiveGoogleMap> {
  GoogleMapController? _controller;
  LatLng? _lastAnimatedMechanic;
  bool _hasFittedInitialMarkers = false;

  static const _fallback = LatLng(31.5204, 74.3587);

  @override
  void didUpdateWidget(covariant LiveGoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _mechanicLatLng(widget.mechanicLocation);
    if (next != null && next != _lastAnimatedMechanic) {
      _lastAnimatedMechanic = next;
      if (!_hasFittedInitialMarkers && widget.customerLocation != null) {
        _hasFittedInitialMarkers = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => _fitMarkers());
      } else {
        _controller?.animateCamera(CameraUpdate.newLatLng(next));
      }
    }
  }

  LatLng? _mechanicLatLng(LiveLocation? location) {
    if (location == null) return null;
    return LatLng(location.latitude, location.longitude);
  }

  Set<Marker> _markers() {
    final markers = <Marker>{};

    if (widget.showCustomerMarker && widget.customerLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('customer_pickup'),
          position: widget.customerLocation!,
          infoWindow: const InfoWindow(title: 'Pickup location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    final mechanic = _mechanicLatLng(widget.mechanicLocation);
    if (widget.showMechanicMarker && mechanic != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('mechanic_live'),
          position: mechanic,
          infoWindow: const InfoWindow(title: 'Mechanic'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          rotation: widget.mechanicLocation!.heading,
        ),
      );
    }

    return markers;
  }

  LatLng _initialTarget() {
    final mechanic = _mechanicLatLng(widget.mechanicLocation);
    return widget.customerLocation ?? mechanic ?? _fallback;
  }

  void _fitMarkers() {
    final points = <LatLng>[];
    if (widget.customerLocation != null) points.add(widget.customerLocation!);
    final mechanic = _mechanicLatLng(widget.mechanicLocation);
    if (mechanic != null) points.add(mechanic);

    if (points.length < 2) {
      if (points.length == 1) {
        _controller?.animateCamera(CameraUpdate.newLatLng(points.first));
      }
      return;
    }

    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final point in points.skip(1)) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    _controller?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        70,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAnyLocation = widget.customerLocation != null || widget.mechanicLocation != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _initialTarget(), zoom: hasAnyLocation ? 14 : 11),
            markers: _markers(),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            onMapCreated: (controller) {
              _controller = controller;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _hasFittedInitialMarkers = true;
                _fitMarkers();
              });
            },
          ),
          if (!hasAnyLocation)
            Positioned.fill(
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.78),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Location is not available yet.\nWaiting for GPS...',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.colors.textMuted),
                    ),
                  ),
                ),
              ),
            ),
          if (widget.mechanicLocation != null)
            Positioned(
              top: 12,
              left: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 9, color: Colors.green),
                      SizedBox(width: 6),
                      Text('Mechanic live'),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
