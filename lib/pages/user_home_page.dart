import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({Key? key}) : super(key: key);

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  late GoogleMapController _mapController;
  LatLng? _homeLocation;
  bool _locationSaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfLocationIsSaved();
  }

  Future<void> _checkIfLocationIsSaved() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists && userDoc.data() != null) {
      var data = userDoc.data() as Map<String, dynamic>;
      setState(() {
        // Safely check if latitude and longitude exist
        _locationSaved = data.containsKey('latitude') && data.containsKey('longitude');
      });
    } else {
      // Handle case when document does not exist or has no data
      setState(() {
        _locationSaved = false;
      });
    }
  }
}

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onTap(LatLng location) {
    setState(() {
      _homeLocation = location;
    });

    _saveLocation(location);
  }

  Future<void> _saveLocation(LatLng location) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Update the user's document in Firestore with the selected location
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'latitude': location.latitude,
          'longitude': location.longitude,
        });

        setState(() {
          _locationSaved = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location saved successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save location: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Home Location'),
        automaticallyImplyLeading: false, // Hide the back button
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            onTap: _locationSaved ? null : _onTap, // Disable tap after saving location
            initialCameraPosition: CameraPosition(
              target: LatLng(37.7749, -122.4194), // Default location (San Francisco)
              zoom: 12,
            ),
            markers: _homeLocation != null
                ? {
                    Marker(
                      markerId: MarkerId('home'),
                      position: _homeLocation!,
                    ),
                  }
                : {},
          ),
          if (_locationSaved)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  // You can navigate to the next page or perform another action here
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                child: Text('Continue'),
              ),
            ),
        ],
      ),
    );
  }
}