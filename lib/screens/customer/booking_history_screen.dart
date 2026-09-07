import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cores/providers/bookings_provider.dart';
import '../../cores/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../../widgets/step_progress.dart';
import 'payment_method_screen.dart';

class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() =>
      _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen> {
  bool _upcoming = true;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final scheme = Theme.of(context).colorScheme;
    final bookingsAsync = ref.watch(bookingsProvider);
    final allBookings = bookingsAsync.valueOrNull ?? const [];
    final list = allBookings.where((b) => b.completed != _upcoming).toList();

    return Scaffold(
      appBar: const FlowAppBar(title: 'Booking History'),
      body: bookingsAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingsAsync.hasError
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Bookings load nahi ho sakin.'),
                  TextButton(
                    onPressed: () => ref.invalidate(bookingsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Chip(
                        label: 'Upcoming',
                        selected: _upcoming,
                        onTap: () => setState(() => _upcoming = true),
                      ),
                      const SizedBox(width: 8),
                      _Chip(
                        label: 'Completed',
                        selected: !_upcoming,
                        onTap: () => setState(() => _upcoming = false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: list.isEmpty
                        ? Center(
                            child: Text(
                              'No bookings found',
                              style: TextStyle(
                                color: c.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: list.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final b = list[i];
                              return InkWell(
                                onTap: b.completed
                                    ? null
                                    : () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => PaymentMethodScreen(
                                            bookingId: b.id,
                                          ),
                                        ),
                                      ),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: c.borderStrong.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            b.service,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '${b.mechanic} · ${b.createdAt == null ? 'Recent' : DateFormat('dd MMM yyyy').format(b.createdAt!.toLocal())}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: c.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'PKR ${b.price}',
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: b.completed
                                                  ? c.success.withValues(
                                                      alpha: 0.15,
                                                    )
                                                  : c.surface2,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              b.completed
                                                  ? 'Completed'
                                                  : 'Pay now',
                                              style: TextStyle(
                                                fontSize: 8.5,
                                                color: b.completed
                                                    ? c.success
                                                    : scheme.primary,
                                              ),
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
                  ),
                ],
              ),
            ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : c.surface2,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: selected ? scheme.onPrimary : c.textSecondary,
          ),
        ),
      ),
    );
  }
}
