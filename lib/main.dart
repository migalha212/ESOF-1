import 'package:eco_finder/firebase_messaging.dart';
import 'package:eco_finder/pages/add_bussiness.dart';
import 'package:eco_finder/pages/landing_page.dart';
import 'package:eco_finder/pages/map_page.dart';
import 'package:eco_finder/pages/navigation_items.dart';
import 'package:eco_finder/pages/notifications_page.dart';
import 'package:eco_finder/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseNotificationService().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eco_finder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF3E8E4D)),
        useMaterial3: true,
      ),
      initialRoute: NavigationItems.navLanding.route,
      routes: {
        NavigationItems.navLanding.route: (context) => const LandingPage(),
        NavigationItems.navMap.route: (context) => const MapPage(),
        NavigationItems.navSearch.route: (context) => const SearchPage(),
        NavigationItems.navAddBusiness.route:
            (context) => const AddBusinessPage(),
        NavigationItems.navNotifications.route:
            (context) => const NotificationsPage(),
      },
    );
  }
}
