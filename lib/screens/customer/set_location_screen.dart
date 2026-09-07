import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cores/config/supabase_config.dart';
import '../../cores/providers/auth_provider.dart';
import '../../cores/providers/booking_draft_provider.dart';
import '../../cores/providers/bookings_provider.dart';
import '../../cores/providers/services_provider.dart';
import '../../cores/repositories/booking_repository.dart';
import '../../cores/theme/app_theme.dart';
import '../../widgets/app_atoms.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/step_progress.dart';
import 'offers_screen.dart';

class SetLocationScreen extends ConsumerStatefulWidget {
  const SetLocationScreen({super.key});

  @override
  ConsumerState<SetLocationScreen> createState() => _SetLocationScreenState();
}

class _SetLocationScreenState extends ConsumerState<SetLocationScreen> {
  final _addressController = TextEditingController();
  final _budgetController = TextEditingController();
  bool _saving = false;

  Future<void> _createBooking() async {
    final draft = ref.read(bookingDraftProvider);
    final userId = ref.read(authProvider).user?.id;
    final services = ref.read(servicesProvider).valueOrNull ?? const [];

    if (userId == null || draft.vehicleId == null || draft.serviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a vehicle and service first.'),
        ),
      );
      return;
    }

    final matchingServices = services.where(
      (service) => service.id == draft.serviceId,
    );
    if (matchingServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected service is no longer available.'),
        ),
      );
      return;
    }

    final service = matchingServices.first;
    final address = _addressController.text.trim();
    final enteredBudget = double.tryParse(_budgetController.text.trim());
    final budget = enteredBudget ?? service.basePrice;

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter pickup address')),
      );
      return;
    }

    if (budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final bookingId = await BookingRepository(supabase).createBooking(
        customerId: userId,
        vehicleId: draft.vehicleId!,
        serviceId: draft.serviceId!,
        serviceTitle: service.title,
        description: draft.description,
        photoUrls: draft.photoUrls,
        address: address,
        budget: budget,
        paymentMethod: 'Cash',
      );

      ref.read(bookingDraftProvider.notifier).setLocation(address);
      ref.invalidate(bookingsProvider);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OffersScreen(bookingId: bookingId)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Request create nahi hui: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: const FlowAppBar(title: 'Pickup Location'),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StepProgress(total: 5, current: 4),
            Expanded(
              child: MapPlaceholder(
                height: double.infinity,
                pins: const [MapPin(top: 100, left: 130, emoji: '📍')],
              ),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Pickup address',
                hintText: 'Enter your current address',
                filled: true,
                fillColor: colors.surface2,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _budgetController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Your budget (optional)',
                prefixText: 'PKR ',
                filled: true,
                fillColor: colors.surface2,
              ),
            ),
            const SizedBox(height: 14),
            AccentButton(
              label: _saving
                  ? 'Creating request...'
                  : 'Confirm & Find Mechanics',
              onPressed: _saving ? null : _createBooking,
            ),
          ],
        ),
      ),
    );
  }
}
