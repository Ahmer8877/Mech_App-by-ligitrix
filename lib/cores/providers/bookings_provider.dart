import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/supabase_config.dart';
import '../models/booking_model.dart';
import '../repositories/booking_repository.dart';
import 'auth_provider.dart';

final bookingRepositoryProvider = Provider(
  (ref) => BookingRepository(supabase),
);
final bookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final id = ref.watch(authProvider.select((s) => s.user?.id));
  if (id == null) return const [];
  return ref.read(bookingRepositoryProvider).getCustomerBookings(id);
});
final mechanicBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final id = ref.watch(authProvider.select((s) => s.user?.id));
  if (id == null) return const [];
  return ref.read(bookingRepositoryProvider).getMechanicBookings(id);
});
final openRequestsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.read(bookingRepositoryProvider).getOpenRequests(),
);
final bookingDetailsProvider =
    FutureProvider.family<Map<String, dynamic>?, String>(
      (ref, id) => ref.read(bookingRepositoryProvider).getRawBooking(id),
    );
