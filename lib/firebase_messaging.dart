import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseNotificationService {

  final _firebaseMessaging = FirebaseMessaging.instance;
  
  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    final fcmtoken = await _firebaseMessaging.getToken();

    print('FCM Token: $fcmtoken');
  }

  void handleMessage(RemoteMessage? message){
    if(message == null) return;
    
  }
}