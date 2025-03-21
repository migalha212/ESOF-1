import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _initialPosition = LatLng(41.17740754929651, -8.596500719923418);
  late GoogleMapController _mapController;
  Location _location = Location();
  Set<Marker> _markers = {};
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
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

      // Marker of initial location

      //setState(() {
      //  _markers.add(
      //    Marker(
      //        markerId: MarkerId('user_location'),
      //        position: LatLng(locationData.latitude!, locationData.longitude!)
      //    ),
      //  );
      //});

      _mapController.animateCamera(CameraUpdate.newLatLng(
          LatLng(locationData.latitude!, locationData.longitude!)
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
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
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: _hovering ? 180 : 160,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFF3E8E4D),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
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
        ],
      ),
    );
  }
}