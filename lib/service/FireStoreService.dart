import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:horaz/service/AuthService.dart';
import 'package:horaz/utils/AppUtils.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cloud function to change message status to delivered
  Future<void> changeMessageStatus(String roomId, String messageId) async {
    try {
      DocumentSnapshot messageSnapshot = await _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .doc(messageId)
          .get();

      Map<String, dynamic>? messageData =
          messageSnapshot.data() as Map<String, dynamic>?;

      if (messageData != null) {
        String status = messageData['status'] ?? '';

        if (['delivered', 'seen', 'sent'].contains(status)) {
          return;
        } else {
          await _firestore
              .collection('rooms')
              .doc(roomId)
              .collection('messages')
              .doc(messageId)
              .update({'status': 'delivered'});
        }
      }
    } catch (e) {
      Logger().e('Error changing message status: $e');
    }
  }

  Future<void> setTypingStatus(
      String roomId, String userId, bool isTyping) async {
    try {
      DocumentReference roomRef = _firestore.collection('rooms').doc(roomId);

      // Fetch existing metadata
      DocumentSnapshot roomSnapshot = await roomRef.get();

      // Explicitly cast data to Map<String, dynamic> or use as Map<String, dynamic>?
      Map<String, dynamic>? currentData =
          roomSnapshot.data() as Map<String, dynamic>?;

      // Extract metadata or initialize an empty map
      Map<String, dynamic> metadata = currentData?['metadata'] ?? {};

      // Update metadata based on typing status
      if (isTyping) {
        metadata[userId] = true;
      } else {
        metadata.remove(userId);
      }

      // Update the room with the modified metadata
      await roomRef.update({'metadata': metadata});
    } catch (e) {
      Logger().e('Error setting typing status: $e');
    }
  }

  bool isUserTyping(types.Room room) {
    final currentUserId = AuthService().firebaseAuth.currentUser?.uid;
    if (currentUserId == null) return false;

    // Check if metadata contains typing information
    if (room.metadata != null && room.metadata!.containsKey(currentUserId)) {
      final typingStatus = room.metadata![currentUserId];
      // Ensure typing status is a boolean
      return typingStatus is bool ? typingStatus : false;
    }

    return false;
  }

  // Cloud function to update room's lastMessages
  Future<void> changeLastMessage(String roomId, String messageId) async {
    try {
      DocumentSnapshot messageSnapshot = await _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .doc(messageId)
          .get();

      Map<String, dynamic>? messageData =
          messageSnapshot.data() as Map<String, dynamic>?;

      if (messageData != null) {
        List<Map<String, dynamic>> lastMessages = [messageData];

        await _firestore
            .collection('rooms')
            .doc(roomId)
            .update({'lastMessages': lastMessages});
      }
    } catch (e) {
      Logger().e('Error changing last message: $e');
    }
  }

  static Future<List<types.User>> getUsers() async {
    if (AuthService().firebaseChatCore.firebaseUser == null) return [];

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      return snapshot.docs.fold<List<types.User>>(
        [],
        (previousValue, doc) {
          if (AuthService().firebaseChatCore.firebaseUser!.uid == doc.id) {
            return previousValue;
          }

          final data = doc.data();

          data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
          data['id'] = doc.id;
          data['lastSeen'] = data['lastSeen']?.millisecondsSinceEpoch;
          data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;

          return [...previousValue, types.User.fromJson(data)];
        },
      );
    } catch (e) {
      // Handle errors if necessary
      log("Error fetching users: $e");
      return [];
    }
  }

  Future getUserData() async {
    try {
      // Get the current user from Firebase Authentication
      final currentUser = AuthService.currentUser;
      Map<String,dynamic> preLoad = {};
      // Fetch user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      // Extract user data
      var userData = userDoc.data() as Map<String, dynamic>;
      final ge = await FirestoreService().getUserFromLocalDB();
      if (ge == null) {
        final localData = await saveMetadataToLocal(userData);
        preLoad.addAll(preLoad);
        return localData;
      }
      return userData;
    } catch (e) {
      // Handle error fetching user data
      log('Error fetching user data: $e');
    }
  }

  Future<void> saveMetadataToLocal(Map<String, dynamic> metadata) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert metadata to encodable map
      final encodableMetadata = AppUtils.encodeMap(metadata);

      // Convert encodable metadata to JSON string
      final jsonString = json.encode(encodableMetadata);

      // Save JSON string to SharedPreferences
      await prefs.setString('userMetadata', jsonString);
    } catch (e) {
      // Handle error saving metadata
      log('Error saving metadata to local storage: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserFromLocalDB() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Retrieve JSON string from SharedPreferences
      final jsonString = prefs.getString('userMetadata');

      // If JSON string exists, parse it into a Map<String, dynamic>
      if (jsonString != null) {
        final parsedMetadata = await json.decode(jsonString);
        // Decode the parsed metadata map
        final decodedMetadata = AppUtils.decodeMap(parsedMetadata);
        // Return the decoded metadata
        return decodedMetadata;
      }
    } catch (e) {
      // Handle error fetching user metadata
      log('Error fetching user metadata from local storage: $e');
    }
  }
}
