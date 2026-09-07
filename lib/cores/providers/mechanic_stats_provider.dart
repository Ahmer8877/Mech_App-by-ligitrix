import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/supabase_config.dart';
import 'auth_provider.dart';

class MechanicDashboardStats {
  final double todayEarnings;
  final double weekEarnings;
  final double monthEarnings;
  final int completedJobs;
  final int ongoingJobs;
  final int pendingRequests;
  final int totalCompletedJobs;
  final String? recentRequestId;
  final String? recentRequestService;
  final String? recentRequestAddress;
  final double? recentRequestBudget;

  const MechanicDashboardStats({
    required this.todayEarnings,
    required this.weekEarnings,
    required this.monthEarnings,
    required this.completedJobs,
    required this.ongoingJobs,
    required this.pendingRequests,
    required this.totalCompletedJobs,
    this.recentRequestId,
    this.recentRequestService,
    this.recentRequestAddress,
    this.recentRequestBudget,
  });

  static const empty = MechanicDashboardStats(
    todayEarnings: 0,
    weekEarnings: 0,
    monthEarnings: 0,
    completedJobs: 0,
    ongoingJobs: 0,
    pendingRequests: 0,
    totalCompletedJobs: 0,
  );
}

final mechanicStatsProvider = FutureProvider<MechanicDashboardStats>((
  ref,
) async {
  final userId = ref.watch(authProvider.select((state) => state.user?.id));
  if (userId == null) return MechanicDashboardStats.empty;

  final client = supabase;
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final weekStart = todayStart.subtract(Duration(days: todayStart.weekday - 1));
  final monthStart = DateTime(now.year, now.month, 1);

  final jobs = await client
      .from('bookings')
      .select('status, agreed_price, budget_price, updated_at, created_at')
      .eq('mechanic_id', userId);

  double earningsSince(DateTime start) {
    var total = 0.0;
    for (final row in jobs) {
      if (row['status']?.toString() != 'completed') continue;
      final date =
          DateTime.tryParse(row['updated_at']?.toString() ?? '') ??
          DateTime.tryParse(row['created_at']?.toString() ?? '');
      if (date == null || date.isBefore(start)) continue;
      total +=
          ((row['agreed_price'] ?? row['budget_price']) as num?)?.toDouble() ??
          0;
    }
    return total;
  }

  final completed = jobs
      .where((row) => row['status']?.toString() == 'completed')
      .length;
  final ongoing = jobs
      .where(
        (row) => const {
          'accepted',
          'on_the_way',
          'in_progress',
        }.contains(row['status']?.toString()),
      )
      .length;

  final pendingRows = await client
      .from('bookings')
      .select('id, service_title, pickup_address, budget_price, created_at')
      .isFilter('mechanic_id', null)
      .eq('status', 'pending')
      .order('created_at', ascending: false);

  final request = pendingRows.isEmpty
      ? null
      : Map<String, dynamic>.from(pendingRows.first);

  return MechanicDashboardStats(
    todayEarnings: earningsSince(todayStart),
    weekEarnings: earningsSince(weekStart),
    monthEarnings: earningsSince(monthStart),
    completedJobs: completed,
    ongoingJobs: ongoing,
    pendingRequests: pendingRows.length,
    totalCompletedJobs: completed,
    recentRequestId: request?['id']?.toString(),
    recentRequestService: request?['service_title']?.toString(),
    recentRequestAddress: request?['pickup_address']?.toString(),
    recentRequestBudget: (request?['budget_price'] as num?)?.toDouble(),
  );
});
