import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseHelper {
  final _firebase = FirebaseAuth.instance;

  final firestoreUser = 'users';
  final firestoreChat = 'chat';
  final firestoreUsernameKey = 'username';
  final firestoreEmaiKey = 'email';
  final firestoreImageUrlKey = 'image_url';
  final firestoreTextKey = 'text';
  final firestoreCreatedAtKey = 'createdAt';
  final firestoreuserIdKey = 'userId';
  final firestoreuserImageKey = 'userImage';

  final firebaseStoreageUserImage = 'user_images';

  Future<UserCredential> login(String email, String password) async {
    final userCredential = await _firebase.signInWithEmailAndPassword(
        email: email, password: password);

    return userCredential;
  }

  Future<UserCredential> signup(String email, String password) async {
    final userCredential = await _firebase.createUserWithEmailAndPassword(
        email: email, password: password);

    return userCredential;
  }

  Future<void> logout() async {
    await _firebase.signOut();
  }

  User? getUser() {
    return _firebase.currentUser;
  }

  Future<String> storageSaveUserImage(String uid, File image) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child(firebaseStoreageUserImage)
        .child('$uid.jpg');
    await storageRef.putFile(image);
    final imageUrl = await storageRef.getDownloadURL();
    return imageUrl;
  }

  Future<void> firestoreSaveUserData(
      String uid, String username, String email, String imageUrl) async {
    await FirebaseFirestore.instance.collection(firestoreUser).doc(uid).set({
      firestoreUsernameKey: username,
      firestoreEmaiKey: email,
      firestoreImageUrlKey: imageUrl,
    });
  }

  Future<void> firestoreNewMessage(String message) async {
    final user = getUser();
    final userData = await firestoreUserData(user!.uid);
    await FirebaseFirestore.instance.collection(firestoreChat).add({
      firestoreTextKey: message,
      firestoreCreatedAtKey: Timestamp.now(),
      firestoreuserIdKey: user.uid,
      firestoreUsernameKey: userData.data()![firestoreUsernameKey],
      firestoreuserImageKey: userData.data()![firestoreImageUrlKey],
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> firestoreUserData(
      String userId) async {
    return await FirebaseFirestore.instance
        .collection(firestoreUser)
        .doc(userId)
        .get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> firestoreGetChat() {
    return FirebaseFirestore.instance
        .collection(firestoreChat)
        .orderBy(firestoreCreatedAtKey, descending: true)
        .snapshots();
  }

  Future<void> fcmToken() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();

    //For receiving notification per device
    final token = await fcm.getToken();
    print('token: ' + token!);

    //For receiving notification per topic
    fcm.subscribeToTopic('chat');
  }
}
