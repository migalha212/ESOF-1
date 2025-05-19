import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum NotificationType { event, storeOpening }

class NotificationModel {
  final String id;
  final String title;
  final DateTime startDate;
  final NotificationType type;
  final String targetId; // even though not used now, keeps future-proof
  final bool read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.startDate,
    required this.type,
    required this.targetId,
    this.read = false,
  });

  /// Builds a ListTile representation of the notification
  Widget toListTile(BuildContext context) {
    final isPastEvent =
        type == NotificationType.event && startDate.isBefore(DateTime.now());
    final bgColor = isPastEvent ? Colors.grey.shade200 : null;
    final icon =
        type == NotificationType.event ? Icons.event : Icons.storefront;
    final formattedDate = DateFormat.yMMMd().add_jm().format(startDate);

    return Container(
      color: bgColor,
      child: ListTile(
        leading: Icon(icon, color: isPastEvent ? Colors.grey : Colors.green),
        title: Text(
          title,
          style: TextStyle(
            color: isPastEvent ? Colors.grey : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          formattedDate,
          style: TextStyle(color: isPastEvent ? Colors.grey : null),
        ),
        onTap: () {
          // You could show a dialog or a placeholder detail screen here
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Tapped: $title')));
        },
      ),
    );
  }
}
