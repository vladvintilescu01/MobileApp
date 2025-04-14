import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ 1. Create a new user
  Future<String> addUser(String name, String desc) async {
    DocumentReference docRef = await _db.collection('users').add({
      'name': name,
      'desc': desc,
    });
    return docRef.id; // Returns the generated user ID
  }

  // ✅ 2. Create a hunt linked to a user
  Future<String> addHunt(String name, String desc, String ownerId) async {
    DocumentReference docRef = await _db.collection('hunts').add({
      'name': name,
      'desc': desc,
      'ownerId': ownerId,
    });
    return docRef.id;
  }

  // ✅ 3. Add a place to a hunt
  Future<String> addPlace(String name, double lat, double long, String desc, String huntId) async {
    DocumentReference docRef = await _db.collection('places').add({
      'name': name,
      'lat': lat,
      'long': long,
      'desc': desc,
      'huntId': huntId,
    });
    return docRef.id;
  }

  // ✅ 4. Add a checklist item to a place
  Future<void> addCheck(String type, String data, String placeId) async {
    await _db.collection('checks').add({
      'type': type,
      'data': data,
      'placeId': placeId,
    });
  }

  // ✅ 5. Create a scavenger hunt (when a player joins a hunt)
  Future<void> startScavengerHunt(String huntId, String userId) async {
    await _db.collection('scavengerHunts').add({
      'huntId': huntId,
      'userId': userId,
      'startDate': Timestamp.now(),
    });
  }

  // ✅ 6. Mark a place as unlocked
  Future<void> unlockPlace(String placeId, String scavHuntId) async {
    await _db.collection('unlockedPlaces').add({
      'placeId': placeId,
      'scavHuntId': scavHuntId,
    });
  }

  // ✅ 7. Add a souvenir when a place is completed
  Future<void> addSouvenir(String checkId, String image, String text, String status, String video) async {
    await _db.collection('souvenirs').add({
      'checkId': checkId,
      'image': image,
      'text': text,
      'status': status,
      'video': video,
    });
  }

  // ✅ 8. Send a notification to the hunt owner
  Future<void> sendHuntNotification(String ownerId, String huntName) async {
    await _db.collection('notifications').add({
      'ownerId': ownerId,
      'message': "'$huntName'",
      'timestamp': Timestamp.now(),
    });
  }

  // ✅ 9. Get all notifications for a specific user
  Stream<List<Map<String, dynamic>>> getNotifications(String ownerId) {
    return _db.collection('notifications')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
