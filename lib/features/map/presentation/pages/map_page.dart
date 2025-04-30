import 'package:eco_finder/features/map/data/business_service.dart';
import 'package:eco_finder/features/map/presentation/widgets/marker_sheet.dart';
import 'package:eco_finder/features/map/presentation/widgets/search_button.dart';
import 'package:eco_finder/utils/navigation_items.dart';
import 'package:eco_finder/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:eco_finder/common_widgets/navbar_widget.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _initialPosition = LatLng(
    41.17740754929651,
    -8.596500719923418,
  );
  late GoogleMapController _mapController;
  final Location _location = Location();
  Set<Marker> _markers = {};
  bool _hovering = false;
  String? _mapStyle; // Stores your custom map style
  LatLng? _userPosition;
  LatLng? _markerPosition;
  Map<String, dynamic>? _markerData;
  Offset? _popUpPosition;

  final int _index = 2;
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
      _userPosition = LatLng(locationData.latitude!, locationData.longitude!);
      _mapController.animateCamera(CameraUpdate.newLatLng(_userPosition!));
    }
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
              setState(() {
                _markerPosition = null;
                _markerData = null;
                _popUpPosition = null;
              });
            },
          ),
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            style: _mapStyle, // Apply the custom map style here
            onMapCreated: (controller) {
              _mapController = controller;
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
                    LatLng center = await _mapController.getLatLng(
                      ScreenCoordinate(
                        x: MediaQuery.of(context).size.width ~/ 2,
                        y: MediaQuery.of(context).size.height ~/ 2,
                      ),
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
