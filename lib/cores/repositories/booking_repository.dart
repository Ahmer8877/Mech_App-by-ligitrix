import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final SupabaseClient client;
  BookingRepository(this.client);

  Future<List<Booking>> getCustomerBookings(String userId) async {
    final rows = await client
        .from('bookings')
        .select(
          '*, mechanic:profiles!bookings_mechanic_id_fkey(full_name,rating), service:services(title)',
        )
        .eq('customer_id', userId)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => Booking.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Booking>> getMechanicBookings(String userId) async {
    final rows = await client
        .from('bookings')
        .select(
          '*, customer:profiles!bookings_customer_id_fkey(full_name,phone_number), service:services(title), vehicle:vehicles(make_model,license_plate,year)',
        )
        .eq('mechanic_id', userId)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => Booking.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getOpenRequests() async {
    final rows = await client
        .from('bookings')
        .select(
          '*, customer:profiles!bookings_customer_id_fkey(full_name,phone_number), service:services(title), vehicle:vehicles(make_model,license_plate,year)',
        )
        .isFilter('mechanic_id', null)
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return (rows as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>?> getRawBooking(String id) async => await client
      .from('bookings')
      .select(
        '*, customer:profiles!bookings_customer_id_fkey(full_name,phone_number), mechanic:profiles!bookings_mechanic_id_fkey(id,full_name,rating,phone_number), service:services(title), vehicle:vehicles(make_model,license_plate,year)',
      )
      .eq('id', id)
      .maybeSingle();
  Future<String> createBooking({
    required String customerId,
    required String vehicleId,
    required String serviceId,
    required String serviceTitle,
    required String description,
    required List<String> photoUrls,
    required String address,
    required double budget,
    required String paymentMethod,
  }) async {
    final row = await client
        .from('bookings')
        .insert({
          'customer_id': customerId,
          'vehicle_id': vehicleId,
          'service_id': serviceId,
          'service_title': serviceTitle,
          'description': description,
          'photo_urls': photoUrls,
          'pickup_address': address,
          'status': 'pending',
          'budget_price': budget,
          'payment_method': paymentMethod,
        })
        .select('id')
        .single();
    return row['id'].toString();
  }

  Future<void> updateStatus(String bookingId, String status) async =>
      client.from('bookings').update({'status': status}).eq('id', bookingId);
  Future<void> cancel(String bookingId) => updateStatus(bookingId, 'cancelled');
  Future<void> complete(String bookingId) =>
      updateStatus(bookingId, 'completed');
  Future<void> markPaid(String bookingId, String method) async => client
      .from('bookings')
      .update({'is_paid': true, 'payment_method': method})
      .eq('id', bookingId);
}
