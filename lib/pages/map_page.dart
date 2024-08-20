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

@override
void initState() {
  super.initState();
  _loadCustomMarker();
  _initializeMap();
  _startLocationTracking(); 
}

void _startLocationTracking() async {
  location.onLocationChanged.listen((loc.LocationData currentLocation) {
    FirebaseFirestore.instance.collection('location').doc(widget.userId).set({
      'latitude': currentLocation.latitude,
      'longitude': currentLocation.longitude,
    }).catchError((e) {
      print("Failed to update location: $e");
    });
  });
}

  void _initializeMap() async {
    // Listen to location changes from the Firestore
    FirebaseFirestore.instance
        .collection('location')
        .doc(widget.userId)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      if (!documentSnapshot.exists) return;

      if (documentSnapshot.data() != null) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        final double latitude = data['latitude'];
        final double longitude = data['longitude'];

        // Update the marker position
        _updateMarkerPosition(latitude, longitude);

        // Optionally, animate camera to focus on the new position
        if (_isMapCreated) {
          _controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: LatLng(latitude, longitude), zoom: 14.47),
            ),
          );
        }
      }
    });
  }

  void _updateMarkerPosition(double latitude, double longitude) {
    setState(() {
      _markers = {
        Marker(
          markerId: MarkerId('user_location'),
          position: LatLng(latitude, longitude),
          icon: customMarker!,
        ),
      };
    });
  }

  Future<void> _loadCustomMarker() async {
    customMarker = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/greentruckicon.png',
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
      body: GoogleMap(
        mapType: MapType.normal,
        markers: _markers,
        initialCameraPosition: CameraPosition(
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
    );
  }
}