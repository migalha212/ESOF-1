import 'package:eco_finder/features/map/data/business_service.dart';
import 'package:eco_finder/features/map/presentation/widgets/marker_sheet.dart';
import 'package:eco_finder/features/notifications/data/notifications_service.dart';
import 'package:eco_finder/features/search/presentation/pages/search_page.dart';
import 'package:eco_finder/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:eco_finder/common_widgets/navbar_widget.dart';
import 'package:eco_finder/features/events/data/event_service.dart';
import 'package:eco_finder/features/events/presentation/widgets/event_sheet.dart';

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
  Set<Marker> _markers = {};
  bool _hovering = false;
  String? _mapStyle; // Stores your custom map style
  bool _isMapReady = false;
  static const double _defaultZoom = 16.0;
  static const double _minZoom = 8.0;
  static const double _maxZoom = 19.0;
  late double _currentZoom;

  final int _index = 2;
  BitmapDescriptor? _eventUpcomingIcon;
  BitmapDescriptor? _eventOngoingIcon;

  @override
  void initState() {
    super.initState();
    _currentZoom = widget.initialZoom ?? _defaultZoom;
    _loadEventIcons();
    _init();
  }

  Future<void> _loadEventIcons() async {
    // Use default marker hues for event markers
    _eventUpcomingIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueOrange,
    );
    _eventOngoingIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueAzure,
    );
    setState(() {});
  }

  Future<void> _init() async {
    await _loadMapStyle();
    await _setInitialPosition();
    await _loadMarkers();
    setState(() {
      _isMapReady = true;
    });
  }

  Future<void> _setInitialPosition() async {
    if (widget.initialPosition != null) {
      _initialPosition = widget.initialPosition;
    } else {
      final userLoc = await LocationService().getCurrentLocation();
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

  Future<void> _loadMarkers() async {
    try {
      final businessMarkers = await MarketService().getBusinessMarkers(
        onTap: (business) async {
          final LatLng marketPosition = LatLng(
            business.latitude,
            business.longitude,
          );

          // Animate the camera to the market position with the default zoom
          await _mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: marketPosition, zoom: _defaultZoom),
            ),
          );
          double zoom = await _mapController.getZoomLevel();
          setState(() {
            _currentZoom = zoom;
          });

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

      final eventMarkers = await EventMarkerService().getEventMarkers(
        onTap: (event) async {
          final LatLng eventPosition = LatLng(event.latitude, event.longitude);

          // Animate the camera to the market position with the default zoom
          await _mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: eventPosition, zoom: _defaultZoom),
            ),
          );
          double zoom = await _mapController.getZoomLevel();
          setState(() {
            _currentZoom = zoom;
          });
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            backgroundColor: Colors.white,
            builder: (context) => EventBottomSheet(event: event),
          );
        },
        upcomingIcon: _eventUpcomingIcon!,
        ongoingIcon: _eventOngoingIcon!,
      );
      setState(() {
        _markers = {...businessMarkers, ...eventMarkers};
      });
    } catch (e) {
      //
    }
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isDisabled,
  }) {
    final borderRadius = BorderRadius.circular(12);

    return Material(
      color: isDisabled ? Colors.grey[200] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: isDisabled ? Colors.grey[300]! : Colors.transparent,
        ),
      ),
      elevation: isDisabled ? 0 : 6,
      child: SizedBox(
        width: 40,
        height: 40,
        child:
            isDisabled
                ? Center(child: Icon(icon, color: Colors.grey[500], size: 22))
                : InkWell(
                  onTap: onPressed,
                  borderRadius: borderRadius,
                  child: Center(
                    child: Icon(icon, color: Colors.black, size: 22),
                  ),
                ),
      ),
    );
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
                zoom: _currentZoom,
              ),
              minMaxZoomPreference: MinMaxZoomPreference(_minZoom, _maxZoom),
              markers: _markers,
              zoomControlsEnabled: false,
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
                        zoom: _currentZoom,
                      ),
                    ),
                  );
                  _currentZoom = await _mapController.getZoomLevel();
                  setState(() {});
                }
              },
              onCameraMove: (CameraPosition position) {
                setState(() {
                  _currentZoom = position.zoom;
                });
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
                          color: Colors.black.withOpacity(0.2),
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
          // Custom Zoom Controls
          Positioned(
            bottom: 20,
            right: 10,
            child: Column(
              children: [
                _buildZoomButton(
                  icon: Icons.add,
                  onPressed:
                      _currentZoom >= _maxZoom
                          ? null
                          : () async {
                            double newZoom = _currentZoom + 1;
                            await _mapController.animateCamera(
                              CameraUpdate.zoomTo(newZoom),
                            );
                            setState(() => _currentZoom = newZoom);
                          },
                  isDisabled: _currentZoom >= _maxZoom,
                ),
                const SizedBox(height: 10),
                _buildZoomButton(
                  icon: Icons.remove,
                  onPressed:
                      _currentZoom <= _minZoom
                          ? null
                          : () async {
                            double newZoom = _currentZoom - 1;
                            await _mapController.animateCamera(
                              CameraUpdate.zoomTo(newZoom),
                            );
                            setState(() => _currentZoom = newZoom);
                          },
                  isDisabled: _currentZoom <= _minZoom,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
