import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LiveLocation {
  final String bookingId;
  final String mechanicId;
  final double latitude;
  final double longitude;
  final double heading;
  final DateTime? updatedAt;

  const LiveLocation({
    required this.bookingId,
    required this.mechanicId,
    required this.latitude,
    required this.longitude,
    this.heading = 0,
    this.updatedAt,
  });

  factory LiveLocation.fromMap(Map<String, dynamic> map) {
    return LiveLocation(
      bookingId: map['booking_id'].toString(),
      mechanicId: map['mechanic_id'].toString(),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      heading: (map['heading'] as num?)?.toDouble() ?? 0,
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? ''),
    );
  }
}

class LiveLocationRepository {
  final SupabaseClient client;

  LiveLocationRepository(this.client);

  Stream<LiveLocation?> watchMechanicLocation(String bookingId) {
    return client
        .from('booking_locations')
        .stream(primaryKey: ['booking_id'])
        .eq('booking_id', bookingId)
        .map((rows) => rows.isEmpty
            ? null
            : LiveLocation.fromMap(Map<String, dynamic>.from(rows.first)));
  }

  static Future<Position?> getCurrentPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    if (!await Geolocator.isLocationServiceEnabled()) {
      return null;
    }
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> updateMechanicLocation({
    required String bookingId,
    required String mechanicId,
    required Position position,
  }) async {
    await client.from('booking_locations').upsert(
      {
        'booking_id': bookingId,
        'mechanic_id': mechanicId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'heading': position.heading.isFinite ? position.heading : 0,
        'speed': position.speed,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'booking_id',
    );
  }

  Future<void> clearMechanicLocation(String bookingId) async {
    await client.from('booking_locations').delete().eq('booking_id', bookingId);
  }
}
