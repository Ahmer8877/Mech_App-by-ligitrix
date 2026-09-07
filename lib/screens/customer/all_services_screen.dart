import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cores/providers/services_provider.dart';
import '../../widgets/app_atoms.dart';
import '../../widgets/step_progress.dart';
import 'select_vehicle_screen.dart';

class AllServicesScreen extends ConsumerWidget {
  const AllServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      appBar: const FlowAppBar(title: 'All Services'),
      body: servicesAsync.when(
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
            return const Center(child: Text('No active services available.'));
          }
          return Padding(
            padding: const EdgeInsets.all(18),
            child: GridView.builder(
              itemCount: services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, i) {
                final service = services[i];
                return ServiceTile(
                  icon: service.icon,
                  label: service.title,
                  onTap: () {
                    ref.read(selectedServiceIdProvider.notifier).state =
                        service.id;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SelectVehicleScreen(),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
