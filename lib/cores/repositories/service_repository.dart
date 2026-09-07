import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_model.dart';

class ServiceRepository {
  final SupabaseClient client;
  ServiceRepository(this.client);

  Future<List<ServiceItem>> getServices() async {
    final rows = await client
        .from('services')
        .select()
        .eq('is_active', true)
        .order('title');
    return (rows as List)
        .map((e) => ServiceItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }
}
