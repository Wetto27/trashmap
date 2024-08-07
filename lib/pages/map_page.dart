import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class MapPage extends StatefulWidget {
  final String user_id;
  MapPage(this.user_id);
  
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _added = false;
  Set<Marker> _markers = {};
  late BitmapDescriptor customMarker;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _loadCustomMarker();
  }

  void _initializeMap() async {
    await location.getLocation();
    location.onLocationChanged.listen((loc.LocationData currentLocation) {
      if (_controller != null) {
        _controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
              zoom: 14.47,
            ),
          ),
        );
      }
    });
  }

  Future<void> _loadCustomMarker() async {
    customMarker = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(48, 48)),
      'assets/images/greentruckicon.png',
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: FirebaseFirestore.instance.collection('location').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (_added) {
          mapPage(snapshot);
        }
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var userLocationData = snapshot.data!.docs.firstWhere(
                (element) => element.id == widget.user_id,
        );
        _markers.clear();
        _markers.add(
            Marker(
              position: LatLng(
                userLocationData['latitude'],
                userLocationData['longitude'],
              ),
              markerId: MarkerId('user_location'),
              icon: customMarker,
            ),
          );

        return GoogleMap(
          mapType: MapType.normal,
          markers: _markers,
          initialCameraPosition: CameraPosition(
              target: LatLng(
                userLocationData['latitude'],
                userLocationData['longitude'],
              ),
              zoom: 14.47),
          onMapCreated: (GoogleMapController controller) {
              _controller = controller;
          },
        );
      },
    ));
  }

  Future<void> mapPage(AsyncSnapshot<QuerySnapshot> snapshot) async {
    await _controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              snapshot.data!.docs.singleWhere(
                  (element) => element.id == widget.user_id)['latitude'],
              snapshot.data!.docs.singleWhere(
                  (element) => element.id == widget.user_id)['longitude'],
            ),
            zoom: 14.47)));
  }
}