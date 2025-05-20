import 'package:eco_finder/common_widgets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:eco_finder/features/notifications/model/notification_model.dart';
import 'package:eco_finder/common_widgets/navbar_widget.dart';
import '../../data/notifications_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for DocumentReference
import 'package:eco_finder/utils/navigation_items.dart'; // Import for route names

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  final int _selectedIndex = 1; // Assuming this is the index for notifications

  Future<List<NotificationModel>> _fetchNotifications() async {
    List<NotificationModel> notifications =
    await NotificationService().fetchNotifications();
    notifications.sort((a, b) => b.startDate.compareTo(a.startDate));
    return notifications;
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    if (notification.type == NotificationType.storeOpening) {
      final storeReference =
      FirebaseFirestore.instance.collection('businesses').doc(notification.targetId);
      print('Tapped Store Notification');
      print('Notification Type: ${notification.type}');
      print('Target ID (Store): ${notification.targetId}');
      print('Store Reference (before navigation): ${storeReference}'); // Log the DocumentReference path
      Navigator.pushNamed(
        context,
        NavigationItems.navSearchProfile.route,
        arguments: storeReference,
      );
    } else if (notification.type == NotificationType.event) {
      Navigator.pushNamed(
        context,
        NavigationItems.navEventProfile.route,
        arguments: notification.targetId,
      );
    }
    // Consider adding a default case or logging if the type is unexpected
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
                return notification.toListTile(
                  context,
                  onTap: (model) => _handleNotificationTap(context, model), // Pass the function here
                );
              },
            );
          }
        },
      ),
    );
  }
}