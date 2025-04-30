import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_finder/features/map/model/eco_market.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:string_similarity/string_similarity.dart';

class SearchService {

  Future<List<EcoMarket>> searchMarkets({
    required String query,
    required List<String> selectedCategories,
    LatLng? referencePosition,
    int maxResults = 10,
  }) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('businesses').get();

    final lowerQuery = query.toLowerCase().trim();
    final threshold = _getSimilarityThreshold(lowerQuery);

    final filtered =
        snapshot.docs
            .where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name_lowercase'] ?? '';
              final categories = List<String>.from(
                data['primaryCategories'] ?? [],
              );

              final bool isSimilar =
                  lowerQuery.isEmpty ||
                  name.contains(lowerQuery) ||
                  StringSimilarity.compareTwoStrings(lowerQuery, name) >=
                      threshold;

              final bool matchesCategory =
                  selectedCategories.isEmpty ||
                  selectedCategories.any((cat) => categories.contains(cat));

              return isSimilar && matchesCategory;
            })
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return EcoMarket(
                id: doc.id,
                name: data['name'],
                latitude: data['latitude'],
                longitude: data['longitude'],
                description: data['description'],
                reference: doc.reference,
              );
            })
            .toList();

    if (referencePosition != null && lowerQuery.isEmpty) {
      filtered.sort((a, b) {
        return _calculateDistance(
          referencePosition,
          a.position,
        ).compareTo(_calculateDistance(referencePosition, b.position));
      });
    } else if (lowerQuery.isNotEmpty) {
      filtered.sort((a, b) {
        final simA = StringSimilarity.compareTwoStrings(
          lowerQuery,
          a.name.toLowerCase(),
        );
        final simB = StringSimilarity.compareTwoStrings(
          lowerQuery,
          b.name.toLowerCase(),
        );
        return simB.compareTo(simA);
      });
    }

    return filtered.take(maxResults).toList();
  }

  double _calculateDistance(LatLng a, LatLng b) {
    const earthRadius = 6371; // km
    final dLat = _degToRad(b.latitude - a.latitude);
    final dLon = _degToRad(b.longitude - a.longitude);
    final aa =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(a.latitude)) *
            cos(_degToRad(b.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(aa), sqrt(1 - aa));
    return earthRadius * c;
  }

  double _degToRad(double degree) => degree * pi / 180;

  double _getSimilarityThreshold(String query) {
    int len = query.length;
    if (len <= 1) return 0.05;
    if (len <= 2) return 0.1;
    if (len <= 4) return 0.15;
    if (len <= 6) return 0.25;
    return (0.3 + (len - 6) * 0.05).clamp(0.0, 0.6);
  }
}