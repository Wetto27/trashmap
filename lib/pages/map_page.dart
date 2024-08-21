import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class MapPage extends StatefulWidget {
  final String userId;
  final bool isWorker;

  MapPage({required this.userId, this.isWorker = false});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _isMapCreated = false;
  Set<Marker> _markers = {};
  BitmapDescriptor? customMarker;
  bool _isTracking = false;

@override
void initState() {
  super.initState();
  _loadCustomMarker();
  _initializeMap();
 if (widget.isWorker) {
      _startLocationTracking();
    }
}

 void _initializeMap() async {
    if (widget.isWorker) {
      // The worker's own map should follow the worker's location.
      location.onLocationChanged.listen((loc.LocationData currentLocation) {
        _updateMarkerPosition(currentLocation.latitude!, currentLocation.longitude!);
        _updateMapLocation(currentLocation.latitude!, currentLocation.longitude!);

        // Update Firestore with the worker's real-time location.
        FirebaseFirestore.instance.collection('locations').doc(widget.userId).set({
          'latitude': currentLocation.latitude,
          'longitude': currentLocation.longitude,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
    } else {
      // For users, listen to the worker's location updates.
      FirebaseFirestore.instance
          .collection('locations')
          .doc(widget.userId) // This should be the worker's userId
          .snapshots()
          .listen((DocumentSnapshot documentSnapshot) {
        if (!documentSnapshot.exists) return;

        if (documentSnapshot.data() != null) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          final double latitude = data['latitude'];
          final double longitude = data['longitude'];

          _updateMarkerPosition(latitude, longitude);
        }
      });
    }
  }

 void _updateMarkerPosition(double latitude, double longitude) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('worker_location'),
          position: LatLng(latitude, longitude),
          icon: customMarker!,
        ),
      };
    });
  }

  void _updateMapLocation(double latitude, double longitude) {
    if (_isMapCreated) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(latitude, longitude), zoom: 14.47),
        ),
      );
    }
  }

  Future<void> _loadCustomMarker() async {
    customMarker = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/greentruckicon.png',
    );
  }

void _startLocationTracking() {
    // Start tracking location updates
    print('Starting location tracking...');
    location.onLocationChanged.listen((loc.LocationData currentLocation) {
      FirebaseFirestore.instance.collection('location').doc(widget.userId).set({
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
      });
    });

    setState(() {
      _isTracking = true;
      print('Live tracking activated: $_isTracking');
    });
  }

  void _stopLocationTracking() {
    // Stop tracking location updates
    print('Stopping location tracking...');
    setState(() {
      _isTracking = false;
      print('Live tracking deactivated: $_isTracking');
    });
  }
  
   void _storeLocation() async {
    final loc.LocationData currentLocation = await location.getLocation();
    await FirebaseFirestore.instance.collection('stored_locations').add({
      'userId': widget.userId,
      'latitude': currentLocation.latitude,
      'longitude': currentLocation.longitude,
      'timestamp': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location stored successfully!')),
    );
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B571D),
        centerTitle: true,
        title: Text(widget.isWorker ? 'Worker Map' : 'User Map',  style: TextStyle(color: Colors.white),),
        leading: IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Navigator.pushNamed(context, '/login'),
    ),
    iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            markers: _markers,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0.0, 0.0), // Initial position; will be updated
              zoom: 14.47,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              setState(() {
                _isMapCreated = true;
              });
            },
          ),
          if (widget.isWorker) // Show buttons only if the user is a worker
            Positioned(
              bottom: 20,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _storeLocation,
                    child: const Text('Armazenar Localização'),
                  ),
                  ElevatedButton(
                    onPressed: _isTracking ? null : _startLocationTracking,
                         child: const Text('Ativar Live Tracking'),
                  ),
                  ElevatedButton(
                    onPressed: _isTracking ? _stopLocationTracking : null,
                    child: const Text('Desligar Live Tracking'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}