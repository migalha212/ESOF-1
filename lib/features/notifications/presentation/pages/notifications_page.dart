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

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    if (notification.type == NotificationType.storeOpening) {
      final storeReference = FirebaseFirestore.instance
          .collection('businesses')
          .doc(notification.targetId);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF3E8E4D),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.white),
        ),
      ),
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
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    leading: Icon(
                      notification.type == NotificationType.storeOpening
                          ? Icons.shopping_bag
                          : Icons.event,
                      color:
                          notification.startDate.isAfter(DateTime.now())
                              ? const Color(0xFF3E8E4D)
                              : Colors.grey,
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      notification.startDate.isAfter(DateTime.now())
                          ? 'Starts on ${notification.startDate.toLocal()}'
                          : 'Ended on ${notification.startDate.toLocal()}',
                      style: TextStyle(
                        color:
                            notification.startDate.isAfter(DateTime.now())
                                ? Colors.black
                                : Colors.grey,
                      ),
                    ),
                    onTap: () => _handleNotificationTap(context, notification),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
