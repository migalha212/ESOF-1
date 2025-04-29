import 'package:eco_finder/pages/navigation_items.dart';
import 'package:eco_finder/pages/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('businesses').get();

      Set<Marker> newMarkers =
          querySnapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            final position = LatLng(data['latitude'], data['longitude']);
            return Marker(
              markerId: MarkerId(doc.id),
              position: position,
                onTap: () async {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    backgroundColor: Colors.white,
                    builder: (BuildContext context) {
                      return FractionallySizedBox(
                        heightFactor: 0.4,
                        widthFactor: 1.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 5,
                                margin: EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              Text(
                                data['name'],
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Text(
                                    data['description'] ?? ' ',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.store),
                                label: Text('Ver página da loja'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF3E8E4D),
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(double.infinity, 45),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
            );
          }).toSet();

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
          if (_markerData != null && _popUpPosition != null)
            Positioned(
              left: _popUpPosition!.dx - 75, // Ajusta conforme o tamanho do widget
              top: _popUpPosition!.dy - 130, // Ajusta para ficar acima do ícone
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 150,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _markerData!['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _markerData!['description'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // ex: ir para detalhes
                        },
                        child: Text('Ver loja'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
