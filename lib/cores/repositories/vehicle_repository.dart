import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vehicle_model.dart';

class VehicleRepository {
  final SupabaseClient client;
  VehicleRepository(this.client);

  Future<List<Vehicle>> getMyVehicles(String userId) async {
    final rows = await client
        .from('vehicles')
        .select()
        .eq('owner_id', userId)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => Vehicle.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Vehicle> addVehicle({
    required String userId,
    required String model,
    required String plate,
    String? year,
  }) async {
    final row = await client
        .from('vehicles')
        .insert(
          Vehicle(model: model, plate: plate, year: year).toInsertMap(userId),
        )
        .select()
        .single();
    return Vehicle.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> deleteVehicle(String id) async {
    await client.from('vehicles').delete().eq('id', id);
  }
}
