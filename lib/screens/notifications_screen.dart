import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final l10n = AppLocalizations.of(context);
    final notifications = appProvider.notifications;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0906),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF5EFE2)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.notificationsTitle,
          style: const TextStyle(
            fontFamily: 'Oswald',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF5EFE2),
          ),
        ),
        actions: [
          if (appProvider.unreadNotificationsCount > 0)
            TextButton(
              onPressed: () {
                appProvider.markAllNotificationsRead();
              },
              child: Text(
                l10n.markAllRead,
                style: const TextStyle(fontSize: 12, color: Color(0xFFF2CF6C)),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF1A160F),
            border: Border.all(
              color: const Color(0xFFF5EFE2).withValues(alpha: 0.07),
            ),
          ),
          child: Column(
            children: notifications.map((notification) {
              final isLast = notification.id == notifications.last.id;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : const Border(
                    bottom: BorderSide(color: Color(0xFFF5EFE2), width: 0.07),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        color: const Color(0xFF221C13),
                      ),
                      child: Icon(
                        _getNotificationIcon(notification.iconType),
                        color: const Color(0xFFF2CF6C),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFF5EFE2),
                                  ),
                                ),
                              ),
                              if (!notification.isRead)
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(left: 8),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFC1272D),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.message,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFA89C85),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getRelativeTime(notification.timestamp, l10n),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6E6452),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String iconType) {
    switch (iconType) {
      case 'membership':
        return Icons.credit_card;
      case 'class':
        return Icons.calendar_today;
      case 'fight':
        return Icons.sports_mma;
      case 'message':
        return Icons.chat_bubble_outline;
      case 'welcome':
        return Icons.celebration;
      default:
        return Icons.info_outline;
    }
  }

  String _getRelativeTime(DateTime timestamp, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inHours < 1) return l10n.minAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
    return DateFormat('dd MMM').format(timestamp);
  }
}