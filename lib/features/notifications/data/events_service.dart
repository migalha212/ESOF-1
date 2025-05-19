import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_finder/features/notifications/model/notification_model.dart';

class NotificationService {
  Future<List<NotificationModel>> fetchNotifications() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('notifications').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return NotificationModel(
        id: doc.id,
        title: data['title'],
        startDate: data['startdate'].toDate(),
        targetId: data['targetId'],
        type:
            data['type']
                ? NotificationType.event
                : NotificationType.storeOpening,
      );
    }).toList();
  }
}
