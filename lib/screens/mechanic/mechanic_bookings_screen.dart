import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cores/providers/bookings_provider.dart';
import '../../cores/theme/app_theme.dart';
import '../../widgets/app_atoms.dart';
import 'on_the_way_screen.dart';

class MechanicBookingsScreen extends ConsumerWidget {
  const MechanicBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(mechanicBookingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: bookings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No bookings yet.'));
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(mechanicBookingsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final booking = items[index];
                final active =
                    booking.status == 'accepted' ||
                    booking.status == 'on_the_way' ||
                    booking.status == 'in_progress';
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: active
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OnTheWayScreen(bookingId: booking.id),
                          ),
                        )
                      : null,
                  child: AppCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.service,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                booking.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: context.colors.textMuted,
                                ),
                              ),
                              if (booking.address.isNotEmpty)
                                Text(
                                  booking.address,
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
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('PKR ${booking.price.toStringAsFixed(0)}'),
                            if (active)
                              const Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                  'Open map →',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
