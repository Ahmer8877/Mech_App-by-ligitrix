import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cores/providers/notifications_provider.dart';
import '../../cores/theme/app_theme.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final c = context.colors;
    final notificationsAsync = ref.watch(notificationsProvider);
    final notifications = notificationsAsync.valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontSize: 15)),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, size: 20),
            tooltip: 'Mark all as read',
            onPressed: () =>
                ref.read(notificationsProvider.notifier).markAllAsRead(),
          ),
        ],
      ),
      body: notificationsAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationsAsync.hasError
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Notifications load nahi ho sakin.'),
                  TextButton(
                    onPressed: () => ref.invalidate(notificationsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : notifications.isEmpty
          ? Center(
              child: Text(
                'No notifications',
                style: TextStyle(color: c.textMuted, fontSize: 12),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final n = notifications[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: n.unread
                        ? scheme.primary.withValues(alpha: 0.06)
                        : null,
                    border: Border.all(
                      color: c.borderStrong.withValues(alpha: 0.35),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: c.surface2,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(n.icon, size: 16, color: scheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              n.subtitle,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: c.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              n.time,
                              style: TextStyle(fontSize: 9, color: c.textMuted),
                            ),
                          ],
                        ),
                      ),
                      if (n.unread)
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: c.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
