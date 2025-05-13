import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EcoMarket {
  final String id;
  final String name;
  final String? description;
  final String? address;
  final String? website;
  final double latitude;
  final double longitude;
  final DocumentReference reference;


  EcoMarket({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.reference,
    this.description,
    this.address,
    this.website,
  });

  LatLng get position => LatLng(latitude, longitude);
}