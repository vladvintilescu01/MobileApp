import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart'; // Import Firebase service
import 'package:image_picker/image_picker.dart';  // Image picker to pick images from the gallery or camera
import 'dart:io';  // To handle the image as a file
import 'package:firebase_storage/firebase_storage.dart';  // To upload the picked image to Firebase Storage
import 'image_picker_upload.dart';  // Your custom image picker and upload logic (create this file if not yet created)
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:visual_detector_ai/visual_detector_ai.dart';


class HuntingPage extends StatefulWidget {
  const HuntingPage({Key? key}) : super(key: key);

  @override
  State<HuntingPage> createState() => _HuntingPageState();
}

class _HuntingPageState extends State<HuntingPage> {
  late GoogleMapController mapController;
  final LatLng _craiova = const LatLng(44.30331514158895, 23.799536797650074);
  final Set<Marker> _markers = {};
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _loadMarkersFromFirestore();
  }

  // ✅ Fetch Places from Firestore and Add Markers
  Future<void> _loadMarkersFromFirestore() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    QuerySnapshot placesSnapshot = await db.collection('places').get();

    Set<Marker> newMarkers = placesSnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(data['lat'], data['long']),
        infoWindow: InfoWindow(
          title: data['name'],
          snippet: data['desc'],
          onTap: () {
            // Show checklist when marker is tapped
            _showChecklistDialog(data['name'], data['huntId'], doc.id);
          },
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    }).toSet();

    setState(() {
      _markers.addAll(newMarkers);
    });
  }

  // ✅ Show Checklist Dialog
  void _showChecklistDialog(String placeName, String huntId, String placeId) {
    showDialog(
      context: context,
      builder: (context) => ChecklistDialog(
        placeName: placeName,
        huntId: huntId,
        placeId: placeId,
        onCheckboxChange: _handleChecklistChange,
      ),
    );
  }

  // ✅ Handle Checklist Change
  void _handleChecklistChange(String placeName, String huntId, String placeId) async {
    // Fetch the hunt details to get the owner ID
    DocumentSnapshot huntDoc = await FirebaseFirestore.instance.collection('hunts').doc(huntId).get();
    String ownerId = huntDoc['ownerId'];

    // Update Firestore and notify the owner
    await _firebaseService.sendHuntNotification(ownerId, "Someone is taking on your Hunt '$placeName'!");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Hunt owner notified!")),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hunting Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) => mapController = controller,
              initialCameraPosition: CameraPosition(target: _craiova, zoom: 14.0),
              markers: _markers,
            ),
          ),
          const Padding(padding: EdgeInsets.all(8.0)),
          Container(
            margin: const EdgeInsets.only(bottom: 44.0),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fetching your next task...')),
                  );
                },
                child: const Text('Give Me My Task'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class ChecklistDialog extends StatefulWidget {
  final String placeName;
  final String huntId;
  final String placeId;
  final Function(String placeName, String huntId, String placeId) onCheckboxChange;

  const ChecklistDialog({
    Key? key,
    required this.placeName,
    required this.huntId,
    required this.placeId,
    required this.onCheckboxChange,
  }) : super(key: key);

  @override
  _ChecklistDialogState createState() => _ChecklistDialogState();
}

class _ChecklistDialogState extends State<ChecklistDialog> {
  File? _imageFile;

  Future<String> uploadImageToFirebase(File imageFile, String checkId) async {
    final fileName = '$checkId.jpg';
    final storageRef = FirebaseStorage.instance.ref().child('Check/$fileName');

    await storageRef.putFile(imageFile);
    final downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  }

  Future<void> updateCheckDocument(String checkId, String imageUrl) async {
    final docRef = FirebaseFirestore.instance.collection('check').doc(checkId);
    await docRef.set({
      'data': imageUrl,
    }, SetOptions(merge: true));
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      final inputImage = InputImage.fromFile(File(pickedFile.path));
      final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);
      final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);

      final imageFile = File(pickedFile.path);
      final isValid = await validateImageWithGemini(imageFile, "Does this image resemble a dog in shape or form?");
 
      if (!mounted) return;

      if (isValid) {
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✅ Image validated successfully!')),
             );
             widget.onCheckboxChange(widget.placeName, widget.huntId, widget.placeId);
             } else {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Image does not meet the requirement. Go hunt yourself!')),
            );
       }

      for (Barcode barcode in barcodes) {
        debugPrint('QR Code found: ${barcode.rawValue}');
      }

      const checkId = 'Kdc3GHG2r9VVosQ0Rrfp';
      final imageUrl = await uploadImageToFirebase(_imageFile!, checkId);
      await updateCheckDocument(checkId, imageUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo uploaded to check!')),
      );

      barcodeScanner.close();
    }else{
        ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('❌ No image selected.')),
         );
        return;
    }
  }

  Future<bool> validateImageWithGemini(File image, String requirement) async {
    try {
      final result = await VisualDetectorAi.analyzeImage(
        image: image,
        geminiApiKey: 'AIzaSyAjZCJ89euHc7V_45Bx1hBN6Y1tlWdS2VE',
        responseLanguage: ResponseLanguage.english,
      );

      print("AI Response: ${result.description}"); // Debugging step

      List<String> validKeywords = ["dog", "puppy", "canine"];
      bool isValid = validKeywords.any((word) => result.description.toLowerCase().contains(word));

      return isValid;
    } catch (e) {
      print('Error during image analysis: $e');
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a picture with a dog'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_imageFile != null)
                Image.file(_imageFile!, height: 300),
              SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                   
                    await _pickImage(); 

                  },
                  child: Text('Take Picture and Validate'),
                ),

            ],
          ),
        ),
      ),
    );
  }
}