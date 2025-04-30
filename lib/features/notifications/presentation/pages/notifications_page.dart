import 'package:eco_finder/common_widgets/appbar_widget.dart';
import 'package:eco_finder/features/notifications/data/events_service.dart';
import 'package:flutter/material.dart';
import 'package:eco_finder/features/notifications/model/notification_model.dart';
import 'package:eco_finder/common_widgets/navbar_widget.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  final int _selectedIndex = 1; // Assuming this is the index for notifications

  Future<List<NotificationModel>> _fetchNotifications() async {
    List<NotificationModel> notifications =
        await EventService().fetchNotifications();
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'Notifications'),
      bottomNavigationBar: NavBar(selectedIndex: _selectedIndex),
      body: FutureBuilder<List<NotificationModel>>(
        future: _fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications available.'));
          } else {
            final notifications = snapshot.data!;
            return ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return notification.toListTile(context);
              },
            );
          }
        },
      ),
    );
  }
}
