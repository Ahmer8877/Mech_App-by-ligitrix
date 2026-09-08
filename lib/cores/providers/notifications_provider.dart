import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/supabase_config.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import 'auth_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(supabase),
);

class NotificationsNotifier extends AsyncNotifier<List<NotificationModel>> {
  NotificationRepository get _repository =>
      ref.read(notificationRepositoryProvider);

  @override
  Future<List<NotificationModel>> build() async {
    final userId = ref.watch(authProvider.select((state) => state.user?.id));

    if (userId == null) return const [];

    return _repository.getForUser(userId);
  }

  Future<void> markAllAsRead() async {
    final userId = ref.read(authProvider).user?.id;

    if (userId == null) return;

    await _repository.markAllRead(userId);

    ref.invalidateSelf();
    await future;
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<NotificationModel>>(
      NotificationsNotifier.new,
    );

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications =
      ref.watch(notificationsProvider).valueOrNull ??
      const <NotificationModel>[];

  return notifications.where((n) => n.unread).length;
});
