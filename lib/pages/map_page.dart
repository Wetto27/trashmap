import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trashmap/widgets/recyclers/custom_app_bar_return.dart';

class MapPage extends StatefulWidget {
  final String user_id;
  MapPage(this.user_id);
  
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _controller;
  Set<Marker> _markers = {};
  late BitmapDescriptor customMarker;
  late BitmapDescriptor homeLocationMarker;
  bool _added = false;

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    _loadHomeLocationMarker();
  }

  Future<void> _loadCustomMarker() async {
    customMarker = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(48, 48)),
      'assets/images/greentruckicon.png',
    );
  }
  
  Future<void> _loadHomeLocationMarker() async {
    homeLocationMarker = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(48, 48)),
      'assets/images/greenhomeicon.png',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBarReturn(context, 'TRASHMAP'),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').doc(widget.user_id).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var userLocationData = snapshot.data!;
          if (!_added) {
            _markers.add(
              Marker(
                position: LatLng(
                  userLocationData['latitude'],
                  userLocationData['longitude'],
                ),
                markerId: MarkerId('home_location'),
                icon: homeLocationMarker,
              ),
            );

            _controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(
                    userLocationData['latitude'],
                    userLocationData['longitude'],
                  ),
                  zoom: 14.47,
                ),
              ),
            );

            setState(() {
              _added = true;
            });
          }

          return GoogleMap(
            mapType: MapType.normal,
            markers: _markers,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                userLocationData['latitude'],
                userLocationData['longitude'],
              ),
              zoom: 14.47,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
          );
        },
      ),
    );
  }
}