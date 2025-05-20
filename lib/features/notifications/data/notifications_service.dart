import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_finder/features/notifications/model/notification_model.dart';

enum NotificationType { event, storeOpening }
class NotificationService {
  Future<List<NotificationModel>> fetchNotifications() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('notifications').get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return NotificationModel(
        id: doc.id,
        title: data['title'] as String,
        startDate: (data['startdate'] as Timestamp).toDate(),
        endDate: (data['enddate'] as Timestamp?)?.toDate(),
        targetId: data['targetId'] as String,
        type: (data['type'] as bool)
            ? NotificationType.event
            : NotificationType.storeOpening,
      );
    }).toList();
  }

  Future<void> createStoreOpeningNotification(
      DocumentSnapshot businessSnapshot) async {
    final businessData = businessSnapshot.data() as Map<String, dynamic>?;
    if (businessData != null && businessData.containsKey('name')) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': 'New Store: ${businessData['name'] as String}',
        'startdate': Timestamp.now(),
        'endate' : Timestamp.now(),
        'targetId': businessSnapshot.id,
        'type': false, // false for store opening
      });
    }
  }

  Future<void> createEventNotification(DocumentSnapshot eventSnapshot) async {
    final eventData = eventSnapshot.data() as Map<String, dynamic>?;
    if (eventData != null &&
        eventData.containsKey('name') &&
        eventData.containsKey('startDate') && // Corrigido para 'startDate'
        eventData.containsKey('endDate')) {   // Corrigido para 'endDate'
      DateTime? startDate;
      DateTime? endDate;

      if (eventData['startDate'] is String) {
        startDate = DateTime.parse(eventData['startDate'] as String);
      } else if (eventData['startDate'] is Timestamp) {
        startDate = (eventData['startDate'] as Timestamp).toDate();
      }

      if (eventData['endDate'] is String) {
        endDate = DateTime.parse(eventData['endDate'] as String);
      } else if (eventData['endDate'] is Timestamp) {
        endDate = (eventData['endDate'] as Timestamp).toDate();
      }

      if (startDate != null) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'title': eventData['name'] as String,
          'startdate': Timestamp.fromDate(startDate),
          'endDate': endDate != null ? Timestamp.fromDate(endDate) : null, // Corrigido para 'endDate'
          'targetId': eventSnapshot.id,
          'type': true, // true for event
        });
      }
    }
  }
}