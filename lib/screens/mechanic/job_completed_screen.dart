import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cores/providers/bookings_provider.dart';
import '../../widgets/app_buttons.dart';
import 'mechanic_home_screen.dart';

class JobCompletedScreen extends ConsumerWidget {
  final String bookingId;

  const JobCompletedScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingDetailsProvider(bookingId));

    return Scaffold(
      body: SafeArea(
        child: booking.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('$error')),
          data: (data) {
            if (data == null) {
              return const Center(child: Text('Booking not found.'));
            }

            final rawAmount = data['agreed_price'] ?? data['budget_price'];
            final amount = rawAmount is num ? rawAmount.toDouble() : 0.0;
            final method = data['payment_method']?.toString() ?? 'Not selected';

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  const Icon(Icons.celebration, size: 56),
                  const SizedBox(height: 14),
                  const Text('Job Completed'),
                  const SizedBox(height: 18),
                  Text('Payment: PKR ${amount.toStringAsFixed(0)}'),
                  Text('Method: $method'),
                  const Spacer(),
                  AccentButton(
                    label: 'Back to Dashboard',
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MechanicHomeScreen(),
                      ),
                      (_) => false,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
