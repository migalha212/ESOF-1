import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Event {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final List<String> primaryCategories;
  final Map<String, dynamic> subcategories;
  final String address;
  final String? website;
  final String? imageUrl;
  final String hostShop;
  final String startDate;
  final String endDate;
  final DocumentReference reference;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.primaryCategories,
    required this.subcategories,
    required this.address,
    this.website,
    this.imageUrl,
    required this.hostShop,
    required this.startDate,
    required this.endDate,
    required this.reference,
  });

  LatLng get position => LatLng(latitude, longitude);

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final lat = data['latitude'];
    final lng = data['longitude'];
    if (lat == null || lng == null) {
      throw Exception('Event document ${doc.id} missing latitude or longitude');
    }
    return Event(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      latitude:
      (lat is num)
          ? lat.toDouble()
          : double.tryParse(lat.toString()) ?? 0.0,
      longitude:
      (lng is num)
          ? lng.toDouble()
          : double.tryParse(lng.toString()) ?? 0.0,
      primaryCategories: List<String>.from(data['primaryCategories'] ?? []),
      subcategories: Map<String, dynamic>.from(data['subcategories'] ?? {}),
      address: data['address'] ?? '',
      website: data['website'],
      imageUrl: data['imageUrl'],
      hostShop: data['hostShop'] ?? '',
      startDate: data['startDate'] ?? '',
      endDate: data['endDate'] ?? '',
      reference: doc.reference,
    );
  }

  // Add this fromMap constructor:
  factory Event.fromMap(String id, Map<String, dynamic> data) {
    final lat = data['latitude'];
    final lng = data['longitude'];
    if (lat == null || lng == null) {
      throw Exception('Event data missing latitude or longitude');
    }
    return Event(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      latitude:
      (lat is num)
          ? lat.toDouble()
          : double.tryParse(lat.toString()) ?? 0.0,
      longitude:
      (lng is num)
          ? lng.toDouble()
          : double.tryParse(lng.toString()) ?? 0.0,
      primaryCategories: List<String>.from(data['primaryCategories'] ?? []),
      subcategories: Map<String, dynamic>.from(data['subcategories'] ?? {}),
      address: data['address'] ?? '',
      website: data['website'],
      imageUrl: data['imageUrl'],
      hostShop: data['hostShop'] ?? '',
      startDate: data['startDate'] ?? '',
      endDate: data['endDate'] ?? '',
      reference: data['reference'] as DocumentReference, // Assuming reference is stored in the map
    );
  }
}