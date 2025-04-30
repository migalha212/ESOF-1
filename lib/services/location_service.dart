import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {

  final Location _location = Location();

  Future<LatLng?> getCurrentLocation() async {
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

    final LocationData locationData = await _location.getLocation();
    if (locationData.latitude == null || locationData.longitude == null) {
      return null;
    }

    return LatLng(locationData.latitude!, locationData.longitude!);
  }
}