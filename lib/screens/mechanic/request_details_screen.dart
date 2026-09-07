import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cores/providers/bookings_provider.dart';
import '../../cores/theme/app_theme.dart';
import '../../widgets/app_atoms.dart';
import '../../widgets/app_buttons.dart';
import 'send_offer_screen.dart';

class RequestDetailsScreen extends ConsumerWidget {
  final String bookingId;
  const RequestDetailsScreen({super.key, required this.bookingId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(bookingDetailsProvider(bookingId));
    return Scaffold(
      appBar: AppBar(title: const Text('Request Details')),
      body: a.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => (Center(child: Text('$e'))),
        data: (b) {
          if (b == null) return const Center(child: Text('Request not found'));
          final customer = b['customer'] as Map?;
          final vehicle = b['vehicle'] as Map?;
          final photos =
              (b['photo_urls'] as List?)?.map((e) => e.toString()).toList() ??
              [];
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Text(
                customer?['full_name']?.toString() ?? 'Customer',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (vehicle != null)
                Text(
                  '${vehicle['make_model'] ?? ''} · ${vehicle['license_plate'] ?? ''}',
                  style: TextStyle(color: context.colors.textMuted),
                ),
              const SizedBox(height: 18),
              const Text('SERVICE'),
              Text(b['service_title']?.toString() ?? ''),
              const SizedBox(height: 16),
              const Text('ISSUE DESCRIPTION'),
              Text(
                b['description']?.toString().isNotEmpty == true
                    ? b['description'].toString()
                    : 'No description provided',
              ),
              const SizedBox(height: 16),
              if (photos.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: photos
                      .map(
                        (u) => ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            u,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 16),
              AppCard(child: Text('📍 ${b['pickup_address'] ?? ''}')),
              const SizedBox(height: 16),
              AppCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('CUSTOMER BUDGET'),
                    Text(
                      'PKR ${((b['budget_price'] as num?) ?? 0).toStringAsFixed(0)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AccentButton(
                label: 'Send Offer',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SendOfferScreen(bookingId: bookingId),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
