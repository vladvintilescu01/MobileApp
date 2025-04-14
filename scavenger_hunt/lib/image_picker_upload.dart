import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerUploader {
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery or camera
  Future<File?> pickImage() async {
    final pickedFile = await _picker.getImage(source: ImageSource.camera); // You can change to ImageSource.gallery for gallery option
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Upload image to Firebase Storage
  Future<String?> uploadImage(File image) async {
    try {
      // Get the image reference in Firebase Storage
      String filePath = 'place_images/${DateTime.now().millisecondsSinceEpoch}.jpg'; 
      TaskSnapshot snapshot = await FirebaseStorage.instance.ref(filePath).putFile(image);

      // Get the download URL for the uploaded image
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }
}
