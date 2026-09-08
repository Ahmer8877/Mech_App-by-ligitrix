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
    final seenTitles = <String>{};
    final services = <ServiceItem>[];

    for (final row in rows as List) {
      final service = ServiceItem.fromMap(Map<String, dynamic>.from(row));
      final key = service.title.trim().toLowerCase();
      if (key.isEmpty || !seenTitles.add(key)) continue;
      services.add(service);
    }

    return services;
  }
}
