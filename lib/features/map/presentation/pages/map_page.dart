import 'package:eco_finder/features/map/data/business_service.dart';
import 'package:eco_finder/features/map/presentation/widgets/marker_sheet.dart';
import 'package:eco_finder/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:eco_finder/common_widgets/navbar_widget.dart';

class MapPage extends StatefulWidget {
  final LatLng? initialPosition;

  const MapPage({super.key, this.initialPosition});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _initialPosition;
  late GoogleMapController _mapController;
  final Location _location = Location();
  Set<Marker> _markers = {};
  bool _hovering = false;
  String? _mapStyle; // Stores your custom map style

  final int _index = 2;
  @override
  void initState() {
    super.initState();
    _loadMapStyle(); // Load the custom map style
    _loadEcoMarkets(); // Load markers
  }

  Future<void> _setInitialPosition() async {
    if (widget.initialPosition != null) {
      _initialPosition = widget.initialPosition;
    } else {
      final userLoc = await _getUserLocation();
      if (userLoc != null) {
        _initialPosition = userLoc;
      }
    }

    print("Initial position is: $_initialPosition");

    if (_initialPosition != null) {
      _mapController.animateCamera(CameraUpdate.newLatLng(_initialPosition!));
    }
  }

  Future<void> _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/map_style.json');
    setState(() {}); // Trigger rebuild to apply the style once loaded
  }

  Future<void> _loadEcoMarkets() async {
    try {
      final newMarkers = await MarketService().getBusinessMarkers(
        onTap: (business) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            backgroundColor: Colors.white,
            builder: (context) => StoreBottomSheet(business: business),
          );
        },
      );

      setState(() {
        _markers = newMarkers;
      });
    } catch (e) {
      //
    }
  }

  Future<LatLng?> _getUserLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return null;
    }

    PermissionStatus permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) return null;
    }

    LocationData locationData = await _location.getLocation();
    print(
      "Got user location: ${locationData.latitude}, ${locationData.longitude}",
    );

    if (locationData.latitude != null && locationData.longitude != null) {
      return LatLng(locationData.latitude!, locationData.longitude!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavBar(selectedIndex: _index),
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              setState(() {});
            },
          ),
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  _initialPosition ??
                  const LatLng(0, 0), // Fallback to (0, 0) if null,
              zoom: 14,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            style: _mapStyle, // Apply the custom map style here
            onMapCreated: (controller) async {
              _mapController = controller;

              // Wait a bit to ensure the map is fully rendered
              await Future.delayed(Duration(milliseconds: 300));

              // Set the initial position after the map is created
              await _setInitialPosition();
            },
          ),

          // Search Button
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: MouseRegion(
                onEnter: (_) => setState(() => _hovering = true),
                onExit: (_) => setState(() => _hovering = false),
                child: GestureDetector(
                  onTap: () async {
                    LatLngBounds bounds =
                        await _mapController.getVisibleRegion();
                    LatLng center = LatLng(
                      (bounds.northeast.latitude + bounds.southwest.latitude) /
                          2,
                      (bounds.northeast.longitude +
                              bounds.southwest.longitude) /
                          2,
                    );

                    // Navigate to the SearchPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => SearchPage(
                              hoveredLatitude: center.latitude,
                              hoveredLongitude: center.longitude,
                            ),
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF3E8E4D),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.manage_search,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Search Stores',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: _hovering ? 22 : 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
