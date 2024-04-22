import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:horaz/screens/HomeScreen/export.dart';
import 'package:horaz/service/AuthService.dart';
import 'package:horaz/service/DBService.dart';
import 'package:horaz/utils/FlutterToast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class AddCommunityController extends GetxController {
  final Map<String, types.User> usersById = {};
  int selectedTagIndex = -1;
  String selectedTagName = '';
  File? communityProfileImage;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }

  void isTagSelected(bool isSelected, int i, String tagTitles) {
    selectedTagIndex = isSelected ? i : -1;
    if (isSelected) {
      selectedTagName = tagTitles;
      update();
    } else {
      selectedTagName = '';
      update();
    }
  }

  void toggleUserSelection(types.User user, bool isSelected) {
    // Toggle isSelected value
    isSelected = !isSelected;
    // Update selectedUsersMap
    if (isSelected) {
      usersById[user.id] = user;
    } else {
      usersById.remove(user.id);
    }
    // Trigger update
    update();
  }

  void removeSelectedUser(String userId) {
    usersById.remove(userId);
    // Trigger update
    update();
  }

  List<String> getSelectedUsers() {
    return usersById.keys.toList();
  }

  Future<void> pickCommunityProfileImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );
    if (image == null) return;
    communityProfileImage = File(image.path);
    update();
  }

  Future<void> createCommunity() async {
    try {
      if (communityProfileImage != null &&
          textEditingController.text.isNotEmpty) {
        CustomLoadingIndicator.customLoading();
        final pic = await DBServiceForStoringOnline.saveProfilePicInStorage(
          File(communityProfileImage!.path),
          AuthService.currentUser!.uid,
          path: 'group_pic',
        );
        final List<types.User> users = usersById.values.toList();
        await AuthService().firebaseChatCore.createGroupRoom(
          imageUrl: pic,
          name: textEditingController.text,
          users: users,
          metadata: {
            "Tag": selectedTagName,
          },
        );
        // For Closing LoadingIndicator
        Get.back();
        // Navigating HomeScreen Screen
        Get.offAllNamed(AppRoutes.homeNavigationScreen);
      } else {
        Get.back();
        if (communityProfileImage == null &&
            textEditingController.text.isEmpty) {
          FlutterToastMsg.flutterToastMSG(
              msg:
                  'Please provide a name and select an image for your community.');
        } else if (communityProfileImage == null) {
          FlutterToastMsg.flutterToastMSG(
              msg: 'Please select an image for your community.');
        } else {
          FlutterToastMsg.flutterToastMSG(
              msg: 'Please provide a name for your community.');
        }
      }
    } catch (e) {
      Get.back();
      log('Error showing while creating room $e');
    }
  }
}
