import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';  // To handle location checks
import 'package:connectivity_plus/connectivity_plus.dart'; // To check internet connectivity
import 'my_guided_hunts_page.dart';
import 'my_account_page.dart';
import 'hunting_page.dart';
import 'new_guided_hunt_page.dart';
import 'package:logger/logger.dart'; 

class DrawerPage extends StatelessWidget {
  const DrawerPage({Key? key}) : super(key: key);

  final List<String> notifications = const [
    'Romanescu Hunt',
    'Pedagogic Hunt',
    'Amaradia',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawer Navigation'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Scavenger Hunt Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('My Account'),
              onTap: () {
                // Navigate to My Account Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyAccountPage(username: 'geo', email: 'geo_nr_1@big.ro', phoneNumber: '077777')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.explore),
              title: const Text('My Hunts'),
              onTap: () {
                // Navigate to My Hunts page using the route '/my_hunts'
                Navigator.pushNamed(context, '/my_hunts');
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('My Guided Hunts'),
              onTap: () {
                // Navigate to My Guilds (you can update this page accordingly)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyGuidedHuntsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                // Navigate to Notifications page
                Navigator.pushNamed(context, '/notify');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // Handle logout logic here
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: notifications.length + 1, // +1 for the "+" button
        itemBuilder: (context, index) {
          if (index == notifications.length) {
            // This is the last item, so show the "+" button
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to "New Guided Hunt" page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewGuidedHuntPage()),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("New Guided Hunt"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            );
          } else {
            // Display each notification card
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                children: [
                  ListTile(
                    title: Text(notifications[index]),
                  ),
                  // Buttons below the card (Hunt Now button)
                  OverflowBar(
                    children: [
                      TextButton(
                        onPressed: () async {
                          // Perform checks before navigating to the Hunting Page
                          int canAccess = await _canAccessHuntingPage();
                          if (canAccess == 1) {
                            // User is not at the location
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Access Denied"),
                                  content: const Text("Go hunt yourself! You're not at the location!"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else if (canAccess == 0) {
                            // User has issues with location or internet
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Access Denied"),
                                  content: const Text("Please check your internet connection or location settings."),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            // If user can access the hunting page
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HuntingPage()),
                            );
                          }
                        },
                        child: const Text("View on map"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

Future<int> _canAccessHuntingPage() async {
  var logger = Logger();

  // Check if location services are enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    logger.i('Location services are not enabled');
    return 0; // If location service is off, return 0
  }

  // Check if location permissions are granted
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    logger.i('Location permission denied');
    return 0; // If location permission denied, return 0
  }

  // Check internet connectivity
  ConnectivityResult connectivity = await Connectivity().checkConnectivity();
  if (connectivity == ConnectivityResult.none) {
    logger.i('No internet connection');
    return 0; // No internet connection
  }

  // Get the user's current position
  Position userPosition;
  try {
    userPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    logger.i('User position: Lat: ${userPosition.latitude}, Long: ${userPosition.longitude}');
  } catch (e) {
    logger.e('Error getting user position: $e');
    return 0; // Return 0 if there's an error getting the user position
  }

  // Actual hunt location coordinates
  double huntLatitude = 44.3362349092137; //44.30038700448905 ;// real coordinate of park
  double huntLongitude = 23.788307891545905; //23.805723158724525; //real coordinate of park

  // Log hunt location for reference
  logger.i('Hunt location: Lat: $huntLatitude, Long: $huntLongitude');

  // Calculate distance between user's current position and the hunt location
  double distanceInMeters;
  try {
    distanceInMeters = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      huntLatitude,
      huntLongitude,
    );
    logger.i('Distance to hunt location: $distanceInMeters meters');
  } catch (e) {
    logger.e('Error calculating distance: $e');
    return 0; // Return 0 if there's an error in distance calculation
  }

  // Check if the user is within a specific distance (e.g., 1000 meters or 1km)
  if (distanceInMeters > 10309238.478453638) {
    // User is not at the location
    logger.i('User is too far from the hunt location.');
    return 1; // Return 1 for not being at the location
  }

  // If everything is fine, user is close enough to the location
  logger.i('User is at the hunt location. Access granted.');
  return 2; // Return 2 for access allowed
}

}
