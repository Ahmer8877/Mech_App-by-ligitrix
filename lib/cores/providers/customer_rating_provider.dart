import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/supabase_config.dart';
import 'auth_provider.dart';

final customerRatingProvider = FutureProvider<double?>((ref) async {
  final userId = ref.watch(authProvider.select((state) => state.user?.id));
  if (userId == null) return null;

  final rows = await supabase
      .from('reviews')
      .select('rating')
      .eq('customer_id', userId);

  if (rows.isEmpty) return null;

  final ratings = rows
      .map((row) => (row['rating'] as num?)?.toDouble())
      .whereType<double>()
      .toList();

  if (ratings.isEmpty) return null;
  return ratings.reduce((a, b) => a + b) / ratings.length;
});
