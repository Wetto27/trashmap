import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

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
    // Escuta as atualizações da localização do worker
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
      // Remove o marcador anterior do worker
      _markers.removeWhere(
          (marker) => marker.markerId == const MarkerId('worker_location'));
      // Adiciona o novo marcador do worker
      _markers.add(
        Marker(
          markerId: const MarkerId('worker_location'),
          position: LatLng(latitude, longitude),
          icon: customMarker!,
        ),
      );
    });

    // Verifica a proximidade do worker com a casa do usuário
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      final homeLocation = data['homeLocation'];
      if (homeLocation != null) {
        LatLng userHomeLatLng =
            LatLng(homeLocation['latitude'], homeLocation['longitude']);
        LatLng workerLatLng = LatLng(latitude, longitude);
        double distance = calculateDistance(userHomeLatLng, workerLatLng);

        if (distance <= 100) {
          // Se o worker estiver a menos de 100 metros da casa do usuário, envia uma notificação
          await _sendNotificationToUser(widget.userId);
        }
      }
    }
  }

  Future<void> showNotification() async {
    // Exibe uma notificação local
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
      // Exibe a notificação
      await showNotification();

      // Define o flag para true para evitar notificações repetidas
      await prefs.setBool('notification_sent_$userId', true);
    }
  }

  void _updateMapLocation(double latitude, double longitude) {
    if (_isMapCreated) {
      // Atualiza a posição da câmera do mapa
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
          // Remove o marcador anterior da casa do usuário
          _markers.removeWhere(
              (marker) => marker.markerId == const MarkerId('home_location'));
          // Adiciona o novo marcador da casa do usuário
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
          // Atualiza a posição da câmera do mapa para a casa do usuário
          _controller.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(latitude, longitude), 14.47),
          );
        }
      }
    }
  }

  Future<void> _loadCustomMarker() async {
    // Carrega o ícone personalizado para o marcador do worker
    customMarker = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/greentruckicon.png',
    );
  }

  Future<void> _loadUserHomeMarker() async {
    // Carrega o ícone personalizado para o marcador da casa do usuário
    userHomeMarker = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/greenhomeicon.png',
    );
  }

  void _startLocationTracking() {
    // Inicia o rastreamento da localização do worker em tempo real
    location.onLocationChanged.listen((loc.LocationData currentLocation) {
      FirebaseFirestore.instance
          .collection('shared_locations')
          .doc('worker_location')
          .set({
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
    // Para o rastreamento da localização do worker
    print('Stopping location tracking...');
    setState(() {
      _isTracking = false;
      print('Live tracking deactivated: $_isTracking');
    });
  }

  void _storeLocation() async {
    // Armazena a localização atual do worker no Firestore
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
          widget.isWorker ? 'Trashmap - Trabalhador' : 'Trashmap',
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
              target: LatLng(-22.2514897,
                  -45.7043553), // Posição inicial; será atualizada
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
          if (widget.isWorker) // Mostra os botões apenas se o usuário for um worker
            Positioned(
                            bottom: 20,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll<Color>(
                          Color(0xFF1B571D),
                        ),
                      ),
                      onPressed: _storeLocation,
                      child: const Text('Armazenar Localização',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll<Color>(
                          Color(0xFF1B571D),
                        ),
                      ),
                      onPressed: _isTracking
                          ? _stopLocationTracking
                          : _startLocationTracking,
                      child: Text(
                          _isTracking
                              ? 'Desativar Live Tracking'
                              : 'Ativar Live Tracking',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  double calculateDistance(LatLng pos1, LatLng pos2) {
    // Calcula a distância entre duas coordenadas geográficas usando a fórmula de Haversine
    const double earthRadius = 6371000; // metros
    double dLat = radians(pos2.latitude - pos1.latitude);
    double dLng = radians(pos2.longitude - pos1.longitude);
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(radians(pos1.latitude)) *
            math.cos(radians(pos2.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distance = earthRadius * c;
    return distance;
  }

  double radians(double degrees) {
    // Converte graus para radianos
    return degrees * (math.pi / 180);
  }
}