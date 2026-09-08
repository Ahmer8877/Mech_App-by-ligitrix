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
final mechanicBookingsProvider = StreamProvider<List<Booking>>((ref) async* {
  final id = ref.watch(authProvider.select((s) => s.user?.id));
  if (id == null) {
    yield const [];
    return;
  }

  final repo = ref.read(bookingRepositoryProvider);
  yield await repo.getMechanicBookings(id);

  yield* supabase
      .from('bookings')
      .stream(primaryKey: ['id'])
      .eq('mechanic_id', id)
      .order('created_at', ascending: false)
      .asyncMap((_) => repo.getMechanicBookings(id));
});
final openRequestsProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) async* {
  final repo = ref.read(bookingRepositoryProvider);
  yield await repo.getOpenRequests();

  yield* supabase
      .from('bookings')
      .stream(primaryKey: ['id'])
      .eq('status', 'pending')
      .asyncMap((_) => repo.getOpenRequests());
});
final bookingDetailsProvider =
    FutureProvider.family<Map<String, dynamic>?, String>(
      (ref, id) => ref.read(bookingRepositoryProvider).getRawBooking(id),
    );
