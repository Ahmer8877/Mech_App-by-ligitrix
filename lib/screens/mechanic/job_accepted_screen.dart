import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cores/providers/bookings_provider.dart';
import '../../widgets/app_buttons.dart';
import 'on_the_way_screen.dart';

class JobAcceptedScreen extends ConsumerWidget {
  final String bookingId;
  const JobAcceptedScreen({super.key, required this.bookingId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(bookingDetailsProvider(bookingId));
    return Scaffold(
      body: SafeArea(
        child: a.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => (Center(child: Text('$e'))),
          data: (b) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                const Icon(Icons.check_circle, size: 56),
                const SizedBox(height: 14),
                const Text('Offer Accepted!'),
                const SizedBox(height: 20),
                Text('📍 ${b?['pickup_address'] ?? ''}'),
                const Spacer(),
                AccentButton(
                  label: 'Start Navigation',
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OnTheWayScreen(bookingId: bookingId),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
