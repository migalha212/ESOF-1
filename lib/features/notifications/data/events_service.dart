import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_finder/features/notifications/model/notification_model.dart';

class EventService {
  Future<List<NotificationModel>> fetchNotifications() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('events').get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return NotificationModel(
        id: doc.id,
        title: data['title'],
        timestamp: data['timestamp'].toDate(),
        targetId: data['targetId'],
        type:
            data['type']
                ? NotificationType.event
                : NotificationType.storeOpening,
      );
    }).toList();
  }
}
