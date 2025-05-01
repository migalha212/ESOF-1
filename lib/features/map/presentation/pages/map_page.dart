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
  final double? initialZoom;

  const MapPage({super.key, this.initialPosition, this.initialZoom});

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
  bool _isMapReady = false;
  static const double _defaultZoom = 16.0;

  final int _index = 2;
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadMapStyle();
    await _setInitialPosition();
    await _loadEcoMarkets();

    setState(() {
      _isMapReady = true;
    });
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
  }

  Future<void> _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/map_style.json');
    setState(() {}); // Trigger rebuild to apply the style once loaded
  }

  Future<void> _loadEcoMarkets() async {
    try {
      final newMarkers = await MarketService().getBusinessMarkers(
        onTap: (business) {
          final LatLng marketPosition = LatLng(
            business.latitude,
            business.longitude,
          );

          // Animate the camera to the market position with the default zoom
          _mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: marketPosition,
                zoom: _defaultZoom, // Set to your default zoom level
              ),
            ),
          );

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

          if (!_isMapReady || _initialPosition == null)
            const Center(child: CircularProgressIndicator())
          else
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition!,
                zoom:
                    widget.initialZoom ??
                    _defaultZoom, // Use passed zoom if any
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              style: _mapStyle, // Apply the custom map style here
              onMapCreated: (controller) async {
                _mapController = controller;
                if (_initialPosition != null) {
                  _mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: _initialPosition!,
                        zoom:
                            widget.initialZoom ??
                            _defaultZoom, // reuse zoom level
                      ),
                    ),
                  );
                }
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

                    // Get current zoom level
                    double zoom = await _mapController.getZoomLevel();

                    final shouldReload = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => SearchPage(
                              hoveredLatitude: center.latitude,
                              hoveredLongitude: center.longitude,
                              zoomLevel: zoom, // Pass zoom
                            ),
                      ),
                    );

                    if (shouldReload == true) {
                      setState(() {
                        _isMapReady = false;
                        _initialPosition = null;
                      });
                      await _init(); // re-trigger loading and location fetch
                    }
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
