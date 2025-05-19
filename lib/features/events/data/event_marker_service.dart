import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_finder/features/events/model/event.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class EventMarkerService {
  Future<List<Event>> fetchEvents() async {
    final snapshot = await FirebaseFirestore.instance.collection('events').get();
    return snapshot.docs
        .map((doc) {
          try {
            return Event.fromFirestore(doc);
          } catch (_) {
            return null;
          }
        })
        .whereType<Event>()
        .toList();
  }

  Future<Set<Marker>> getEventMarkers({
    required void Function(Event) onTap,
    required BitmapDescriptor upcomingIcon,
    required BitmapDescriptor ongoingIcon,
  }) async {
    final events = await fetchEvents();
    final now = DateTime.now();
    final Set<Marker> markers = {};
    for (final event in events) {
      final start = DateTime.tryParse(event.startDate);
      final end = DateTime.tryParse(event.endDate);
      if (start == null || end == null) continue;
      // Allow events that are ongoing or upcoming (including today)
      final isOngoing = start.isBefore(now) && end.isAfter(now.subtract(const Duration(days: 1)));
      final isUpcoming = start.isAtSameMomentAs(now) || (start.isAfter(now.subtract(const Duration(days: 1))) && start.difference(now).inDays < 3);
      if (!isUpcoming && !isOngoing) continue;
      BitmapDescriptor icon = isUpcoming ? upcomingIcon : ongoingIcon;
      markers.add(
        Marker(
          markerId: MarkerId('event_${event.id}'),
          position: event.position,
          icon: icon,
          onTap: () => onTap(event),
        ),
      );
    }
    return markers;
  }
}
