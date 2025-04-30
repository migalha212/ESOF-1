import 'package:eco_finder/common_widgets/appbar_widget.dart';
import 'package:eco_finder/utils/navigation_items.dart';
import 'package:flutter/material.dart';
import 'package:eco_finder/features/notifications/notification_model.dart';
import 'package:eco_finder/common_widgets/navbar_widget.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);
  final int _selectedIndex = 1; // Assuming this is the index for notifications
  List<NotificationModel> _mockNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: '1',
        title: 'New Store Opening: Eco Boutique',
        timestamp: now.subtract(const Duration(hours: 5)),
        type: NotificationType.storeOpening,
        targetId: 'store_1',
      ),
      NotificationModel(
        id: '2',
        title: 'Eco Market Event at Central Park',
        timestamp: now.subtract(const Duration(days: 1)),
        type: NotificationType.event,
        targetId: 'event_2',
      ),
      NotificationModel(
        id: '3',
        title: 'Upcoming: Reuse Workshop',
        timestamp: now.add(const Duration(hours: 3)),
        type: NotificationType.event,
        targetId: 'event_3',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _mockNotifications();
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return Scaffold(
      appBar: AppBarWidget(title: 'Notifications'),
      bottomNavigationBar: NavBar(selectedIndex: _selectedIndex),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return notification.toListTile(context);
        },
      ),
    );
  }
}
