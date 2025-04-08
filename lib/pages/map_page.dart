import 'package:EcoFinder/pages/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show rootBundle;

//import 'landing_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _initialPosition =
  LatLng(41.17740754929651, -8.596500719923418);
  late GoogleMapController _mapController;
  final Location _location = Location();
  Set<Marker> _markers = {};
  bool _hovering = false;
  String? _mapStyle; // Stores your custom map style

  @override
  void initState() {
    super.initState();
    _loadMapStyle(); // Load the custom map style
    _getUserLocation();
    _loadEcoMarkets();
  }

  Future<void> _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/map_style.json');
    setState(() {}); // Trigger rebuild to apply the style once loaded
  }

  Future<void> _loadEcoMarkets() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('businesses').get();

      print("🔍 Número de mercados encontrados: ${querySnapshot.docs.length}");

      Set<Marker> newMarkers = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        print(
            "📌 Mercado encontrado: ${data['name']}, Lat: ${data['latitude']}, Lng: ${data['longitude']}");
        return Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(data['latitude'], data['longitude']),
          infoWindow:
          InfoWindow(title: data['name'], snippet: data['description']),
        );
      }).toSet();

      setState(() {
        _markers = newMarkers;
      });

      print("✅ Marcadores adicionados: ${_markers.length}");
    } catch (e) {
      print("❌ Erro ao carregar mercados: $e");
    }
  }

  void _getUserLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) return;
    }

    LocationData locationData = await _location.getLocation();
    if (locationData.latitude != null && locationData.longitude != null) {
      _mapController.animateCamera(CameraUpdate.newLatLng(
          LatLng(locationData.latitude!, locationData.longitude!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
            CameraPosition(target: _initialPosition, zoom: 14),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            style: _mapStyle, // Apply the custom map style here
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: MouseRegion(
                onEnter: (_) => setState(() => _hovering = true),
                onExit: (_) => setState(() => _hovering = false),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to the SearchPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SearchPage()),
                    );
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: _hovering ? 180 : 160,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF3E8E4D),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'EcoFinder',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: _hovering ? 22 : 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
