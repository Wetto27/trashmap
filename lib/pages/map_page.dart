  import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_local_notifications/flutter_local_notifications.dart';
  import 'package:google_maps_flutter/google_maps_flutter.dart';
  import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';
  import 'dart:math' as math;

  import 'package:trashmap/main.dart';

  class MapPage extends StatefulWidget {
    final String userId;
    final bool isWorker;

    MapPage({super.key, required this.userId, this.isWorker = false});

    @override
    _MapPageState createState() => _MapPageState();
  }

  class _MapPageState extends State<MapPage> {
    final loc.Location location = loc.Location();
    late GoogleMapController _controller;
    bool _isMapCreated = false;
    Set<Marker> _markers = {};
    BitmapDescriptor? customMarker;
    BitmapDescriptor? userHomeMarker;
    bool _isTracking = false;

  @override
    void initState() {
      super.initState();
      _loadCustomMarker();
      _loadUserHomeMarker();
      _initializeMap();
      if (!widget.isWorker) {
        _loadUserHomeLocation();
      }
    }

  void _initializeMap() {
      FirebaseFirestore.instance
          .collection('shared_locations')
          .doc('worker_location')
          .snapshots()
          .listen((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          final double latitude = data['latitude'];
          final double longitude = data['longitude'];

          _updateMarkerPosition(latitude, longitude);
        }
      });
    }

  void _updateMarkerPosition(double latitude, double longitude) async {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId == const MarkerId('worker_location'));
      _markers.add(
        Marker(
          markerId: const MarkerId('worker_location'),
          position: LatLng(latitude, longitude),
          icon: customMarker!,
        ),
      );
    });

    // Check proximity to user's home location
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      final homeLocation = data['homeLocation'];
      if (homeLocation != null) {
        LatLng userHomeLatLng = LatLng(homeLocation['latitude'], homeLocation['longitude']);
        LatLng workerLatLng = LatLng(latitude, longitude);
        double distance = calculateDistance(userHomeLatLng, workerLatLng);

        if (distance <= 100) { // Threshold distance in meters
          // Send notification to the user
          await _sendNotificationToUser(widget.userId);
        }
      }
    }
  }

 Future<void> showNotification() async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 10,
      channelKey: 'worker_proximity',
      title: 'Worker Near Your Home',
      body: 'The worker is near your home location!',
      notificationLayout: NotificationLayout.BigPicture,
    ),
  );
}

Future<void> _sendNotificationToUser(String userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool notificationSent = prefs.getBool('notification_sent_$userId') ?? false;

  if (!notificationSent) {
    // Show notification
    await showNotification();

    // Set the flag to true
    await prefs.setBool('notification_sent_$userId', true);
  }
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

    Future<void> _loadUserHomeLocation() async {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final homeLocation = data['homeLocation'];
        if (homeLocation != null) {
          final double latitude = homeLocation['latitude'];
          final double longitude = homeLocation['longitude'];

          setState(() {
            _markers.removeWhere((marker) => marker.markerId == const MarkerId('home_location'));
            _markers.add(
              Marker(
                markerId: const MarkerId('home_location'),
                position: LatLng(latitude, longitude),
                icon: userHomeMarker!,
                infoWindow: const InfoWindow(title: 'Home Location'),
              ),
            );
          });

          if (_isMapCreated) {
            _controller.animateCamera(
              CameraUpdate.newLatLngZoom(LatLng(latitude, longitude), 14.47),
            );
          }
        }
      }
    }

    Future<void> _loadCustomMarker() async {
      customMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/images/greentruckicon.png',
      );
    }

    Future<void> _loadUserHomeMarker() async {
      userHomeMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/images/greenhomeicon.png',  
      );
    }

  void _startLocationTracking() {
    location.onLocationChanged.listen((loc.LocationData currentLocation) {
      FirebaseFirestore.instance.collection('shared_locations').doc('worker_location').set({
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });


    setState(() {
      _isTracking = true;
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
          title: Text(
            widget.isWorker ? 'Worker Map' : 'User Map',
            style: const TextStyle(color: Colors.white),
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
              mapType: MapType.normal,
              markers: _markers,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-22.2514897, -45.7043553), // Initial position; will be updated
                zoom: 14.47,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                setState(() {
                  _isMapCreated = true;
                  if (!widget.isWorker) {
                    _loadUserHomeLocation();
                  }
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
                      child: const Text('Desativar Live Tracking'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

      double calculateDistance(LatLng pos1, LatLng pos2) {
      const double earthRadius = 6371000; // meters
      double dLat = radians(pos2.latitude - pos1.latitude);
      double dLng = radians(pos2.longitude - pos1.longitude);
      double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
          math.cos(radians(pos1.latitude)) * math.cos(radians(pos2.latitude)) *
              math.sin(dLng / 2) * math.sin(dLng / 2);
      double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
      double distance = earthRadius * c;
      return distance;
    }

    double radians(double degrees) {
      return degrees * (math.pi / 180);
    }

  }