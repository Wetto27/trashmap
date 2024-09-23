import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectHomeLocationPage extends StatefulWidget {
  final String userId;

  const SelectHomeLocationPage({super.key, required this.userId});

  @override
  _SelectHomeLocationPageState createState() => _SelectHomeLocationPageState();
}

class _SelectHomeLocationPageState extends State<SelectHomeLocationPage> {
  late GoogleMapController _controller;
  LatLng? _selectedLocation;
  bool _isMapCreated = false;
  final loc.Location _location = loc.Location();
  String? _address;

  @override
  void initState() {
    super.initState();
    _location.requestPermission();
  }

  Future<void> _getDeviceLocation() async {
    // Obtém a localização atual do dispositivo e centraliza o mapa nessa localização
    final currentLocation = await _location.getLocation();
    _controller.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(currentLocation.latitude!, currentLocation.longitude!),
      15,
    ));
  }

  void _onMapTapped(LatLng position) async {
    setState(() {
      _selectedLocation = position;
    });

    // Obtém o endereço a partir das coordenadas
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        setState(() {
          _address =
              '${placemark.street}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}';
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  Future<void> _saveHomeLocation() async {
    if (_selectedLocation != null) {
      // Salva a localização selecionada no Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'homeLocation': {
          'latitude': _selectedLocation!.latitude,
          'longitude': _selectedLocation!.longitude,
          'address': _address,
        }
      });

      // Navega para a página do mapa do usuário
      Navigator.pushReplacementNamed(context, '/userMap',
          arguments: widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1B571D),
        title: Text(
          "Selecione seu endereço",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/login'),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(-22.2514897, -45.7043553),
              zoom: 2,
            ),
            onMapCreated: (controller) {
              _controller = controller;
              _getDeviceLocation();
              setState(() {
                _isMapCreated = true;
              });
            },
            onTap: _onMapTapped,
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selectedLocation'),
                      position: _selectedLocation!,
                    ),
                  }
                : {},
          ),
          Positioned(
            bottom: 20,
            left: 100,
            right: 100,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(
                  Color(0xFF1B571D),
                ),
              ),
              onPressed: _saveHomeLocation,
              child: const Text(
                'Continuar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}