import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:horaz/models/CallHistoryModel.dart';
import 'package:horaz/models/ProfileModel.dart';
import 'package:horaz/service/AuthService.dart';
import 'package:horaz/utils/AppUtils.dart';
import 'package:logger/logger.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class DBServiceForStoringOnline {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  static final roomCollection = firestore.collection('rooms');

  static Future<void> saveProfileData({
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePic,
    String? currentUserUid,
  }) async {
    try {
      final CollectionReference users = firestore.collection('users');
      final String documentId = currentUserUid ?? '';

      // Create a map of the profile data with optional fields
      final ProfileModel data = ProfileModel(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        profilePic: profilePic,
      );

      // Save the data to Cloud FireStore
      await users.doc(documentId).set(data.toJson());

      Logger().i('Profile data saved successfully');
    } catch (e) {
      // Handle errors here (e.g., display an error message)
      Logger().e('Error saving profile data: $e');
    }
  }

  static Future<String?> saveProfilePicInStorage(File imageFile, String userId,
      {String? path = 'profile_pics'}) async {
    try {
      final String fileName = imageFile.path
          .split('/')
          .last;
      final storageReference =
      _firebaseStorage.ref().child('$userId/$path/$fileName');

      await storageReference.putFile(imageFile);

      final String downloadUrl = await storageReference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      Logger().e('Error uploading profile picture: $e');
      return null;
    }
  }

  static Future<String?> saveMediaInStorage({
    required File imageFile,
    required String userId,
    required String authorId,
  }) async {
    try {
      final String fileName = imageFile.path
          .split('/')
          .last;
      final storageReference = _firebaseStorage
          .ref()
          .child('chatsMedia/$userId/$authorId/$fileName');

      await storageReference.putFile(imageFile);

      final String downloadUrl = await storageReference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      Logger().e('Error uploading profile picture: $e');
      return null;
    }
  }

  static Future<String?> saveMediaFileInStorage({
    required File imageFile,
    required String userId,
    required String authorId,
  }) async {
    try {
      final String fileName = imageFile.path
          .split('/')
          .last;
      final storageReference = _firebaseStorage
          .ref()
          .child('chatsMedia/$userId/$authorId/$fileName');

      await storageReference.putFile(imageFile);

      final String downloadUrl = await storageReference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  static Future<void> updateProfileField({
    String? field,
    dynamic value,
    String? currentUserUid,
  }) async {
    try {
      final CollectionReference users = firestore.collection('users');
      final String documentId = currentUserUid ?? '';

      // Create a map with a single field to update
      final Map<String, dynamic> updatedField = {field!: value};

      // Update the user document with the new data
      await users.doc(documentId).update(updatedField);

      Logger().i('Profile field updated successfully');
    } catch (e) {
      // Handle errors here (e.g., display an error message)
      Logger().e('Error updating profile field: $e');
    }
  }

  static Future<void> setUserOffline(String userId) async {
    final Timestamp timestamp = AppUtils.updatedAtFunc();
    await DBServiceForStoringOnline.firestore
        .collection('users')
        .doc(userId)
        .update({'isOnline': 'offline'});
    DBServiceForStoringOnline.firestore
        .collection('users')
        .doc(userId)
        .update({'lastSeen': timestamp});
    DBServiceForStoringOnline.firestore
        .collection('users')
        .doc(userId)
        .update({'updatedAt': timestamp});
  }

  static Future<void> setUserOnline(String userId) async {
    await DBServiceForStoringOnline.firestore
        .collection('users')
        .doc(userId)
        .update({'isOnline': 'online'});
  }

  Future<void> updateRoom({types.Room? room, // Make room nullable
    String? newName,
    String? newTag,
    String? imageUrl}) async {
    if (AuthService.currentUser == null || room == null) return;

    try {
      final roomData = <String, dynamic>{};

      // Update name if provided
      if (newName != null && newName.isNotEmpty) {
        roomData['name'] = newName;
      }

      // Update tag if provided
      if (newTag != null && newTag.isNotEmpty) {
        roomData['metadata'] = {'Tag': newTag};
      }

      // Update image URL if provided
      if (imageUrl != null && imageUrl.isNotEmpty) {
        roomData['imageUrl'] = imageUrl;
      }

      // Update last messages if available
      if (room.lastMessages != null) {
        final lastMessagesData = room.lastMessages!
            .map((message) =>
        {
          'authorId': message.author.id,
          ...message.toJson(),
          'createdAt':
          Timestamp.fromMillisecondsSinceEpoch(message.createdAt!),
          'updatedAt':
          Timestamp.fromMillisecondsSinceEpoch(message.updatedAt!),
        })
            .toList();
        roomData['lastMessages'] = lastMessagesData;
      }

      // Update updatedAt field
      roomData['updatedAt'] = FieldValue.serverTimestamp();

      // Perform the update
      await firestore
          .collection(AuthService().firebaseChatCore.config.roomsCollectionName)
          .doc(room.id)
          .update(roomData);
    } catch (e) {
      log('Error updating room: $e');
    }
  }

  static storeDataOnFireStore({
    required String fireStoreCollectionName,
    required CallHistoryModel data,
  }) async {
    try {
      final collection = firestore.collection(fireStoreCollectionName);

      // Convert CallHistoryModel object to JSON
      final jsonData = data.toJson();

      // Use custom ID or let Firestore generate one
      await collection.doc(data.id).set(jsonData);

      log("Document added");
    } on FirebaseException catch (e) {
      log(e.toString());
    }
  }

  static Future<Map<String, dynamic>> getUpdatedRoomDataAsFuture(
      types.Room room) async {
    try {
      final updatedRoomSnapshot =
      await DBServiceForStoringOnline.roomCollection.doc(room.id).get();

      final Map<String, dynamic> updatedRoomData =
      updatedRoomSnapshot.data() as Map<String, dynamic>;

      return updatedRoomData;
    } catch (e) {
      // Handle the error
      Logger().e('Error fetching updated room data: $e');
      return {}; // Return an empty map or handle the error as needed
    }
  }
}
