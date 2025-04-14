import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'hunting_page.dart'; // Assuming you have this page already
import 'package:flutter/services.dart'; // For SystemNavigator to exit app (optional)

class HuntingAccessCheckScreen extends StatefulWidget {
  @override
  _HuntingAccessCheckScreenState createState() => _HuntingAccessCheckScreenState();
}

class _HuntingAccessCheckScreenState extends State<HuntingAccessCheckScreen> {
  bool _isLoading = true;
  bool _isUserAtLocation = false;

  // Location coordinates (static values, could be dynamic)
  final double requiredLatitude = 44.3302; // Example hunt latitude
  final double requiredLongitude = 23.7949; // Example hunt longitude
  final double allowedRadius = 100; // Radius in meters

  @override
  void initState() {
    super.initState();
    _checkUserLocation();
  }

  // Function to check the user's current location
  Future<void> _checkUserLocation() async {
    Position currentPosition;

    try {
      // Request location permission
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
        });
        // If permissions are denied, display a message and exit
        _showPermissionDeniedDialog();
        return;
      }

      // Check if the location service is enabled (e.g., GPS is turned on)
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
        });
        _showLocationServiceDisabledDialog();
        return;
      }

      // Get the current position (latitude and longitude)
      currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // Check if user is within the allowed radius from the target location
      double distanceInMeters = Geolocator.distanceBetween(
        currentPosition.latitude, 
        currentPosition.longitude, 
        requiredLatitude, 
        requiredLongitude,
      );

      if (distanceInMeters <= allowedRadius) {
        setState(() {
          _isUserAtLocation = true;
        });
      }

      setState(() {
        _isLoading = false;
      });

      // Navigate based on location
      if (_isUserAtLocation) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HuntingPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(
                child: Text(
                  "Go hunt yourself! You're not at the location!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // If an error occurs (e.g., location service is disabled)
      _showErrorDialog();
    }
  }

  // Dialog to show if location permission is denied
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Location Permission Denied"),
        content: const Text(
          "Please enable location services to proceed with the hunt.",
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.pop(context);
              SystemNavigator.pop(); // Optionally close the app if permission denied
            },
          ),
        ],
      ),
    );
  }

  // Dialog to show if location services are disabled
  void _showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Location Services Disabled"),
        content: const Text(
          "Please enable location services (GPS) to proceed with the hunt.",
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.pop(context);
              SystemNavigator.pop(); // Optionally close the app if location service is disabled
            },
          ),
        ],
      ),
    );
  }

  // Dialog to show if there was an error fetching location
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: const Text(
          "An error occurred while fetching your location. Please try again.",
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.pop(context);
              SystemNavigator.pop(); // Optionally close the app if error occurs
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checking Location"),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator() // Show loading spinner while checking location
            : const Text('Please wait...'), // Placeholder text
      ),
    );
  }
}
