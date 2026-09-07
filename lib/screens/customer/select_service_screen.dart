import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cores/providers/services_provider.dart';
import '../../cores/providers/booking_draft_provider.dart';
import '../../cores/theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/step_progress.dart';
import 'issue_details_screen.dart';

class SelectServiceScreen extends ConsumerWidget {
  const SelectServiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final scheme = Theme.of(context).colorScheme;
    final servicesAsync = ref.watch(servicesProvider);
    final selectedId = ref.watch(selectedServiceIdProvider);

    return Scaffold(
      appBar: const FlowAppBar(title: 'Select Service'),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StepProgress(total: 5, current: 2),
            Expanded(
              child: servicesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Services load nahi ho sakin.'),
                      TextButton(
                        onPressed: () => ref.invalidate(servicesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (services) {
                  if (services.isEmpty) {
                    return const Center(
                      child: Text('No active services available.'),
                    );
                  }
                  final effectiveId =
                      selectedId != null &&
                          services.any((s) => s.id == selectedId)
                      ? selectedId
                      : services.first.id;
                  if (selectedId == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        ref.read(selectedServiceIdProvider.notifier).state =
                            effectiveId;
                      }
                    });
                  }
                  return ListView.separated(
                    itemCount: services.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final service = services[i];
                      final selected = service.id == effectiveId;
                      return InkWell(
                        onTap: () =>
                            ref.read(selectedServiceIdProvider.notifier).state =
                                service.id,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? scheme.primary
                                  : c.borderStrong.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: c.surface2,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Icon(
                                  service.icon,
                                  size: 16,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service.title,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      service.description,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: c.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'PKR ${service.basePrice.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: scheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            AccentButton(
              label: 'Next',
              onPressed: selectedId == null
                  ? null
                  : () {
                      final draft = ref.read(bookingDraftProvider);
                      ref
                          .read(bookingDraftProvider.notifier)
                          .setSelection(
                            vehicleId: draft.vehicleId,
                            serviceId: selectedId,
                          );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const IssueDetailsScreen(),
                        ),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
