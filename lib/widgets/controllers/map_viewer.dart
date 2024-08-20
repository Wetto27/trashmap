import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:trashmap/widgets/recyclers/custom_app_bar_return.dart';
import 'package:trashmap/pages/map_page.dart';

class MapViewer extends StatefulWidget {
  const MapViewer({super.key});

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  _MapViewerState createState() => _MapViewerState();
}

class _MapViewerState extends State<MapViewer> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBarReturn(context, 'TRASHMAP'),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('location').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Redirect to the first available location in the snapshot
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MapPage(userId: snapshot.data!.docs[0].id),
              ),
            );
          });

          return const Center(child: Text('Redirecting to map...'));
        },
      ),
    );
  }

  Future<void> _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('Location permission granted.');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}