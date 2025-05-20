import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/notifications_service.dart'; // Import NotificationService to access NotificationType

class NotificationModel {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime? endDate;
  final NotificationType type;
  final String targetId; // even though not used now, keeps future-proof
  final bool read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.targetId,
    this.read = false,
  });

  /// Builds a ListTile representation of the notification
  Widget toListTile(BuildContext context, {required Function(NotificationModel) onTap}) {
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
          onTap(this); // Call the provided onTap callback
        },
      ),
    );
  }
}