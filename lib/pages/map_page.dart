import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:trashmap/pages/constants.dart';

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
  late BitmapDescriptor customMarker;

  static const LatLng originLocation = LatLng(-22.260631539226832, -45.71273108247909);
  static const LatLng destinationLocation = LatLng(-22.25700928414701, -45.69673024914108);

  List<LatLng> polylineCoordinates = [];

  void getPolyPoints() async{
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: chaveApiGoogle,
      request: PolylineRequest(
        origin: PointLatLng(originLocation.latitude, originLocation.longitude), 
        destination: PointLatLng(destinationLocation.latitude, destinationLocation.longitude), 
        mode: TravelMode.driving,
      ),
    );

    if(result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
            LatLng(point.latitude, point.longitude)
        ),
      );
      setState(() {});
    }
  }

  @override
  void initState() {
    getPolyPoints();
    _initializeMap();
    _loadCustomMarker();
    super.initState();
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
        return GoogleMap(
          mapType: MapType.normal,
          polylines: {
            Polyline(
              polylineId: PolylineId("route"),
              points: polylineCoordinates,
              color: Color(0xFF1B571D),
              width: 3
            ),
          },
          markers: {
            Marker(
                position: LatLng(
                  snapshot.data!.docs.singleWhere(
                      (element) => element.id == widget.user_id)['latitude'],
                  snapshot.data!.docs.singleWhere(
                      (element) => element.id == widget.user_id)['longitude'],
                ),
                markerId: MarkerId('id'),
               icon: customMarker,
            ),
            Marker(markerId: MarkerId("origin"),
            position: originLocation,
            ),
            Marker(markerId: MarkerId("destination"),
            position: destinationLocation,
            ),
          },
          initialCameraPosition: CameraPosition(
              target: LatLng(
                snapshot.data!.docs.singleWhere(
                    (element) => element.id == widget.user_id)['latitude'],
                snapshot.data!.docs.singleWhere(
                    (element) => element.id == widget.user_id)['longitude'],
              ),
              zoom: 14.47),
          onMapCreated: (GoogleMapController controller) async {
            setState(() {
              _controller = controller;
              _added = true;
            });
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