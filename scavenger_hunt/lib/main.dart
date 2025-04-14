import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'hunting_access_check_screen.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'hunting_page.dart';
import 'drawer_page.dart';
import 'my_hunts_page.dart';
import 'my_guided_hunts_page.dart';
import 'edit_guided_hunt_page.dart';
import 'notify_page.dart';
import 'new_guided_hunt_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ScavengerHuntApp());
}

class ScavengerHuntApp extends StatelessWidget {
  const ScavengerHuntApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scavenger Hunt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const LoginPage(), // ✅ Users enter the app normally
      routes: {
        '/register': (context) => const RegisterPage(),
        '/drawer': (context) => const DrawerPage(),
        '/my_hunts': (context) => const MyHuntsPage(),
        '/my_guided_hunts': (context) => const MyGuidedHuntsPage(),
        '/notify': (context) => const NotifyPage(),
        '/new_guided_hunts': (context) => const NewGuidedHuntPage(),
      },
      onGenerateRoute: (settings) {
  if (settings.name == '/hunting') {
    return MaterialPageRoute(builder: (context) => HuntingAccessCheckScreen());
  }

  if (settings.name == '/edit_guided_hunt_page') {
    final args = settings.arguments as Map<String, dynamic>?;

    if (args == null || !args.containsKey('huntName')) {
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(child: Text('No hunt data provided')),
        ),
      );
    }

    return MaterialPageRoute(
      builder: (context) => EditGuidedHuntPage(huntName: args['huntName']!),
    );
  }

  return null;
},

    );
  }
}

// ✅ Function to check if the user is at the required hunt location
Future<bool> _isUserAtHuntLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // ✅ Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return false;
  }

  // ✅ Check location permissions
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return false;
  }

  // ✅ Get user location
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  const double requiredLatitude = 44.3302;
  const double requiredLongitude = 23.7949;
  const double allowedRadius = 100; // 100 meters

  double distance = Geolocator.distanceBetween(
    position.latitude, position.longitude, requiredLatitude, requiredLongitude,
  );

  return distance <= allowedRadius;
}
