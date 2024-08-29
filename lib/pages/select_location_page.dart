import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
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
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _location.requestPermission();
  }

  Future<void> _getDeviceLocation() async {
    final currentLocation = await _location.getLocation();
    _controller.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(currentLocation.latitude!, currentLocation.longitude!),
      15,
    ));
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  Future<void> _saveHomeLocation() async {
    if (_selectedLocation != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'homeLocation': {
          'latitude': _selectedLocation!.latitude,
          'longitude': _selectedLocation!.longitude,
        }
      });

      // Navigate to the user map page
      Navigator.pushReplacementNamed(context, '/userMap',
          arguments: widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Home Location'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
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
            left: 10,
            right: 10,
            child: ElevatedButton(
              onPressed: _saveHomeLocation,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}