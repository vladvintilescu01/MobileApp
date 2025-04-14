import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // GPS access
import 'package:permission_handler/permission_handler.dart'; // Permission handling
import 'package:connectivity_plus/connectivity_plus.dart'; // Internet check
import 'hunting_page.dart';

class LocationCheckScreen extends StatefulWidget {
  final double requiredLatitude;
  final double requiredLongitude;
  final double allowedRadius;

  LocationCheckScreen({
    required this.requiredLatitude,
    required this.requiredLongitude,
    required this.allowedRadius,
  });

  @override
  _LocationCheckScreenState createState() => _LocationCheckScreenState();
}

class _LocationCheckScreenState extends State<LocationCheckScreen> {
  bool isLocationPermissionGranted = false;
  bool isGpsEnabled = false;
  bool isConnectedToInternet = false;
  bool isUserAtLocation = false;

  @override
  void initState() {
    super.initState();
    _checkConditions();
  }

  Future<void> _checkConditions() async {
    await _checkLocationPermission();
    await _checkInternetConnection();
    await _checkGps();
    await _checkUserLocation();
  }

  // ✅ Check Location Permission
  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.status;

    if (status.isGranted) {
      setState(() {
        isLocationPermissionGranted = true;
      });
    } else {
      var result = await Permission.location.request();
      if (result.isGranted) {
        setState(() {
          isLocationPermissionGranted = true;
        });
      }
    }
  }

  // ✅ Check if GPS is enabled
  Future<void> _checkGps() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    setState(() {
      isGpsEnabled = serviceEnabled;
    });
  }

  // ✅ Check Internet Connection
  Future<void> _checkInternetConnection() async {
    ConnectivityResult result = await Connectivity().checkConnectivity();
    setState(() {
      isConnectedToInternet = result != ConnectivityResult.none;
    });
  }

  // ✅ Check if User is at the Required Location
  Future<void> _checkUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double distanceInMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      widget.requiredLatitude,
      widget.requiredLongitude,
    );

    setState(() {
      isUserAtLocation = distanceInMeters <= widget.allowedRadius;
    });

    // ✅ If all conditions are met, navigate to HuntingPage
    if (isLocationPermissionGranted && isGpsEnabled && isConnectedToInternet && isUserAtLocation) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HuntingPage()),
      );
    } else {
      _showMessage("You need to be at the required location with GPS & Internet enabled!");
    }
  }

  // Show message using SnackBar
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location & Internet Check')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!isLocationPermissionGranted) Text('Location permission required.'),
            if (!isGpsEnabled) Text('GPS is disabled.'),
            if (!isConnectedToInternet) Text('No internet connection.'),
            if (!isUserAtLocation) Text('You are not at the required location.'),

            ElevatedButton(
              onPressed: _checkConditions,
              child: Text('Recheck Status'),
            ),
          ],
        ),
      ),
    );
  }
}
