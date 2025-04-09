import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:location/location.dart' as device_location;

class LocationPicker extends StatefulWidget {
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final TextEditingController addressController;

  const LocationPicker({
    super.key,
    required this.latitudeController,
    required this.longitudeController,
    required this.addressController,
  });

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  GoogleMapController? _mapController;
  LatLng _selectedPosition = LatLng(41.1579, -8.6291); // Default: Porto
  Marker? _selectedMarker;

  @override
  void initState() {
    super.initState();
    _initializeUserLocation();
    _setMarker(_selectedPosition);
  }

  Future<void> _initializeUserLocation() async {
    final device_location.Location location = device_location.Location();

    // Verifica e solicita o serviço de localização
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    // Verifica e solicita permissão de localização
    device_location.PermissionStatus permissionGranted =
    await location.hasPermission();
    if (permissionGranted == device_location.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != device_location.PermissionStatus.granted) {
        return;
      }
    }

    // Obtém a localização do dispositivo
    final locData = await location.getLocation();
    final userPosition = LatLng(locData.latitude!, locData.longitude!);

    setState(() {
      _selectedPosition = userPosition;
      _setMarker(_selectedPosition);
    });
    widget.latitudeController.text = _selectedPosition.latitude.toString();
    widget.longitudeController.text = _selectedPosition.longitude.toString();

    // Caso o controlador do mapa já esteja disponível, centraliza para a posição do utilizador
    _mapController?.animateCamera(CameraUpdate.newLatLng(_selectedPosition));
    _updateAddressFromLatLng(_selectedPosition);
  }

  void _setMarker(LatLng position) {
    setState(() {
      _selectedMarker = Marker(
        markerId: MarkerId('selected'),
        position: position,
        draggable: true,
        onDragEnd: (newPosition) {
          _updatePosition(newPosition);
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    });
    _updatePosition(position);
  }

  Future<void> _updatePosition(LatLng position) async {
    widget.latitudeController.text = position.latitude.toString();
    widget.longitudeController.text = position.longitude.toString();
    _selectedPosition = position;
    await _updateAddressFromLatLng(position);
  }

  Future<void> _updateAddressFromLatLng(LatLng position) async {
    try {
      List<geocoding.Placemark> placemarks =
      await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String address =
        "${place.street ?? ''}, ${place.locality ?? ''}".trim();
        widget.addressController.text = address;
      }
    } catch (e) {
      widget.addressController.text = "Endereço não encontrado";
    }
  }

  Future<void> _searchAddress(String address) async {
    try {
      List<geocoding.Location> locations =
      await geocoding.locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final newPosition = LatLng(loc.latitude, loc.longitude);
        _mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
        _setMarker(newPosition);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Endereço não encontrado')),
      );
    }
  }

  void _onMapTap(LatLng tappedPosition) {
    _setMarker(tappedPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Campo para busca de endereço
        TextFormField(
          controller: widget.addressController,
          decoration: InputDecoration(
            labelText: 'Endereço',
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.search,
          onFieldSubmitted: _searchAddress,
        ),
        const SizedBox(height: 10),
        // Exibição das coordenadas
        Text(
          'Lat: ${_selectedPosition.latitude.toStringAsFixed(6)}, Lng: ${_selectedPosition.longitude.toStringAsFixed(6)}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 10),
        // Mapa interativo com reconhecimento de gestos para impedir scroll na área do mapa
        SizedBox(
          height: 300,
          child: GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _selectedPosition,
              zoom: 15,
            ),
            markers: _selectedMarker != null ? {_selectedMarker!} : {},
            onTap: _onMapTap,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
              ),
            },
          ),
        ),
      ],
    );
  }
}
