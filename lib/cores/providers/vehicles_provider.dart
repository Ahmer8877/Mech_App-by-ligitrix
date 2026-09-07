import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/supabase_config.dart';
import '../models/vehicle_model.dart';
import '../repositories/vehicle_repository.dart';
import 'auth_provider.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>(
  (ref) => VehicleRepository(supabase),
);

class VehiclesNotifier extends AsyncNotifier<List<Vehicle>> {
  late final VehicleRepository _repository;

  @override
  Future<List<Vehicle>> build() async {
    _repository = ref.read(vehicleRepositoryProvider);
    final userId = ref.watch(authProvider.select((state) => state.user?.id));
    if (userId == null) return const [];
    return _repository.getMyVehicles(userId);
  }

  Future<bool> addVehicle(String model, String plate, {String? year}) async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.addVehicle(
        userId: userId,
        model: model,
        plate: plate,
        year: year,
      );
      return _repository.getMyVehicles(userId);
    });
    return !state.hasError;
  }

  Future<bool> removeVehicle(String id) async {
    if (id.isEmpty) return false;
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteVehicle(id);
      return _repository.getMyVehicles(userId);
    });
    return !state.hasError;
  }
}

final vehiclesProvider = AsyncNotifierProvider<VehiclesNotifier, List<Vehicle>>(
  VehiclesNotifier.new,
);
final selectedVehicleIdProvider = StateProvider<String?>((ref) => null);
