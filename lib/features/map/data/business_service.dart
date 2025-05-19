import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_finder/features/map/model/eco_market.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarketService {
  Future<List<EcoMarket>> fetchBusinesses() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('businesses').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return EcoMarket(
        id: doc.id,
        name: data['name'],
        latitude: data['latitude'],
        longitude: data['longitude'],
        description: data['description'],
        address: data['address'],
        website: data['website'],
        reference: doc.reference,
      );
    }).toList();
  }

  Future<Set<Marker>> getBusinessMarkers({
    required void Function(EcoMarket) onTap,
  }) async {
    final businesses = await fetchBusinesses();

    return businesses.map((business) {
      return Marker(
        markerId: MarkerId(business.id),
        position: business.position,
        onTap: () => onTap(business),
      );
    }).toSet();
  }
}



