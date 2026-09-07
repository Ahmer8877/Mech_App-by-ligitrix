import 'package:flutter/material.dart';
import '../../cores/theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/step_progress.dart';

class NewVehicleResult {
  final String make;
  final String plate;
  final String? year;
  const NewVehicleResult(this.make, this.plate, {this.year});
}

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _makeController = TextEditingController();
  final _plateController = TextEditingController();
  final _yearController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _makeController.dispose();
    _plateController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_makeController.text.trim().isEmpty ||
        _plateController.text.trim().isEmpty) {
      setState(() => _error = 'Make/Model and License Plate are required');
      return;
    }
    setState(() => _error = null);
    Navigator.of(context).pop(
      NewVehicleResult(
        _makeController.text.trim(),
        _plateController.text.trim(),
        year: _yearController.text.trim().isEmpty
            ? null
            : _yearController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: const FlowAppBar(title: 'Add Vehicle'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 36,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 100,
                          height: 70,
                          decoration: BoxDecoration(
                            color: c.surface2,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.directions_car_outlined,
                            size: 30,
                            color: c.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'MAKE & MODEL',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: c.textMuted,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _makeController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Suzuki Alto',
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'LICENSE PLATE',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: c.textMuted,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _plateController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. LEZ 2022',
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'YEAR (OPTIONAL)',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: c.textMuted,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'e.g. 2022',
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style: TextStyle(fontSize: 11.5, color: c.danger),
                        ),
                      ],
                      const Spacer(),
                      const SizedBox(height: 16),
                      AccentButton(label: 'Add Vehicle', onPressed: _submit),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
