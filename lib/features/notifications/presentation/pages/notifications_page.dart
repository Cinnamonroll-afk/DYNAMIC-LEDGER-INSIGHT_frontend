import 'package:flutter/material.dart';
import 'package:fincontrol/core/widgets/glass_container.dart';
import 'package:fincontrol/features/notifications/data/models/notification_model.dart';
import 'package:fincontrol/features/notifications/data/repositories/notification_repository.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationRepository _repo = NotificationRepository();
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _userId = ''; // Backend JWT infers userId
  }

  void _markAllAsRead() {
    if (_userId.isNotEmpty) {
      _repo.markAllAsRead(_userId);
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'market': return Icons.trending_up;
      case 'goal': return Icons.flag;
      case 'ai': return Icons.auto_awesome;
      case 'budget': return Icons.warning_amber_rounded;
      case 'bill': return Icons.calendar_today;
      default: return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'market': return Colors.greenAccent.shade400;
      case 'goal': return Colors.orangeAccent;
      case 'ai': return Colors.blueAccent;
      case 'budget': return Colors.redAccent.shade400;
      case 'bill': return Colors.purpleAccent;
      default: return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final mutedTextColor = Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        gradient: isDarkMode 
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
            )
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF8FAFC), Color(0xFFE0E7FF)],
            ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Notifications',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextButton(
                      onPressed: _markAllAsRead,
                      child: Text(
                        'Mark read',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<NotificationModel>>(
                  stream: _repo.getNotifications(_userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final notifications = snapshot.data ?? [];
                    if (notifications.isEmpty) {
                      return Center(
                        child: Text("You're all caught up!", style: TextStyle(color: mutedTextColor)),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 24),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        final isRead = notif.isRead;
                        final iconColor = _getColorForType(notif.type);

                        return Dismissible(
                          key: Key(notif.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            _repo.deleteNotification(notif.id);
                          },
                          child: GestureDetector(
                            onTap: () {
                              if (!isRead) _repo.markAsRead(notif.id);
                            },
                            child: GlassContainer(
                              padding: const EdgeInsets.all(16),
                              border: isRead ? null : Border.all(color: primaryColor.withValues(alpha: 0.5), width: 1.5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: iconColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(_getIconForType(notif.type), color: iconColor),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                notif.title,
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              _formatTime(notif.createdAt),
                                              style: TextStyle(
                                                color: mutedTextColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notif.message,
                                          style: TextStyle(
                                            color: isRead ? mutedTextColor : textColor,
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isRead) ...[
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(top: 6),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
