import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_finder/firebase_messaging.dart';
import 'package:eco_finder/pages/add_bussiness.dart';
import 'package:eco_finder/pages/landing_page.dart';
import 'package:eco_finder/features/map/presentation/pages/map_page.dart';
import 'package:eco_finder/pages/store_profile_page.dart';
import 'package:eco_finder/utils/navigation_items.dart';
import 'package:eco_finder/features/notifications/presentation/pages/notifications_page.dart';
import 'package:eco_finder/features/search/presentation/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseNotificationService().initNotifications();
  runApp(const MyApp());
}

PageRouteBuilder<dynamic> navigationFade({
  required RouteSettings settings,
  required Widget Function() builder,
  Duration transitionDuration = const Duration(milliseconds: 200),
  Duration reverseTransitionDuration = const Duration(milliseconds: 150),
}) {
  return PageRouteBuilder(
    settings: settings,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
    pageBuilder: (context, animation, secondaryAnimation) => builder(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
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
      onGenerateRoute: (settings) {
        final routeBuilders = {
          NavigationItems.navMap.route: () {
            return navigationFade(
              settings: settings,
              builder: () => const MapPage(),
            );
          },
          NavigationItems.navLanding.route: () {
            return navigationFade(
              settings: settings,
              builder: () => const LandingPage(),
            );
          },
          NavigationItems.navSearch.route: () {
            return navigationFade(
              settings: settings,
              builder: () => const SearchPage(),
            );
          },
          NavigationItems.navNotifications.route: () {
            return navigationFade(
              settings: settings,
              builder: () => const NotificationsPage(),
            );
          },
          NavigationItems.navAddBusiness.route: () {
            return navigationFade(
              settings: settings,
              builder: () => const AddBusinessPage(),
            );
          },
          NavigationItems.navMapProfile.route: () {
            return navigationFade(
              settings: settings,
              builder:
                  () => StoreProfilePage(
                    storeRef: settings.arguments as DocumentReference,
                  ),
            );
          },
          NavigationItems.navSearchProfile.route: () {
            return navigationFade(
              settings: settings,
              builder:
                  () => StoreProfilePage(
                    storeRef: settings.arguments as DocumentReference,
                  ),
            );
          },
        };
        // Select the correct route builder
        final routeBuilder = routeBuilders[settings.name];
        return routeBuilder != null ? routeBuilder() : null;
      },
    );
  }
}
