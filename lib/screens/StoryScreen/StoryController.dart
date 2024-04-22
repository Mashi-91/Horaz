import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/models/StoryModel.dart';
import 'package:horaz/screens/StoryScreen/StoryViewFullScreen.dart';

class StoryController extends GetxController {
  final _storyStreamController = StreamController<List<StoryModel>>.broadcast();
  Stream<List<StoryModel>> get storyStream => _storyStreamController.stream;

  var myStories = <StoryModel>[].obs;
  var otherUserStories = <StoryModel>[].obs;
  List<StoryModel> uniqueStories = [];

  @override
  void onInit() {
    fetchAllStories(); // Fetch stories when the controller is initialized
    super.onInit();
  }

  void processOtherUserStories() {
    final userIds = otherUserStories.map((story) => story.userId).toSet();
    for (var userId in userIds) {
      final userStories = otherUserStories
          .where((story) => story.userId == userId)
          .toList();
      uniqueStories.add(userStories.first); // Add the first story for each user
    }
    otherUserStories.assignAll(uniqueStories);
  }

  Future<void> uploadStory(StoryModel story) async {
    await FirebaseFirestore.instance.collection('stories').add(story.toJson());
  }

  Future<void> fetchAllStories() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        log('Error: Current user not available');
        return;
      }

      final currentUserId = currentUser.uid;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('stories')
          .get();

      final allStories = querySnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data();
        if (data != null) {
          return StoryModel.fromJson(data);
        } else {
          log('Error: Document data is null');
          return null;
        }
      }).whereType<StoryModel>().toList(); // Filter out null values

      // Seperate current user stories and other users stories
      myStories.assignAll(allStories.where((story) => story.userId == currentUserId));
      otherUserStories.assignAll(allStories.where((story) => story.userId != currentUserId));
      processOtherUserStories();

      _storyStreamController.add(allStories);
    } catch (e) {
      log('Error fetching stories: $e');
    }
  }

  void deleteStory(String fileName) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        // Handle the case where the current user is null
        return;
      }

      // Delete document from Firestore
      await FirebaseFirestore.instance.collection('stories').doc('storyId').delete();

      // Delete video file from Cloud Storage
      final videoRef = FirebaseStorage.instance
          .ref()
          .child('stories/${currentUser.uid}/$fileName');
      await videoRef.delete();

      // Delete thumbnail image file from Cloud Storage
      final thumbnailRef = FirebaseStorage.instance
          .ref()
          .child('stories/${currentUser.uid}/thumbnails/$fileName.jpg');
      if (thumbnailRef != null) {
        await thumbnailRef.delete();
      }

      update();
    } catch (e) {
      log('Error deleting story: $e');
      // Handle errors if any
    }
  }

  void navigateToFullStoryScreen({
    required BuildContext context,
    required List<StoryModel> storyModel,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        fullscreenDialog: true,
        barrierColor: AppColors.greyColor.withOpacity(0.3),
        pageBuilder: (_, __, ___) => Dialog(
          elevation: 0,
          backgroundColor: AppColors.greyColor.withOpacity(0.3),
          insetPadding: EdgeInsets.zero,
          child: StoryViewFullScreen(
            storyModel: storyModel,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _storyStreamController.close();
    super.dispose();
  }
}
