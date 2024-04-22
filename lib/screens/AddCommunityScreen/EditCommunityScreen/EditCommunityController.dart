import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/constants/AppConst.dart';
import 'package:horaz/screens/AddCommunityScreen/AddCommunityWidget.dart';
import 'package:horaz/service/AuthService.dart';
import 'package:horaz/service/DBService.dart';
import 'package:horaz/utils/AppUtils.dart';
import 'package:horaz/utils/CustomLoading.dart';
import 'package:image_picker/image_picker.dart';

class EditCommunityController extends GetxController {
  final scrollController = ScrollController();
  Map<String, dynamic> updatedRoom = {};
  Rx<File> changeImage = File('').obs;
  RxString changeTag = ''.obs;
  RxString updatedTextEditing = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    final types.Room room = Get.arguments;
    tagScrollCurrentPosition(room);
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose(); // Don't forget to dispose the scroll controller
  }

  void updateTextEditingFunc(val) {
    updatedTextEditing.value = val;
  }

  void tagScrollCurrentPosition(types.Room room) {
    // Find the index of the selected tag
    int selectedIndex = AppConst.tagNames.indexOf(room.metadata?['Tag']);

    // Calculate the initial scroll position based on the selected index
    final double initialScrollPosition =
        selectedIndex != -1 ? selectedIndex * (120 + 8) : 0.0;

    // After the build method
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Scroll to the initial position after the build is complete
      scrollController.animateTo(
        initialScrollPosition,
        duration: const Duration(seconds: 2),
        curve: Curves.bounceOut,
      );
    });
  }

  Future<void> changeImageFunc() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    changeImage.value = File(image.path);
  }

  void isTagSelected(
      bool isSelected, int i, String tagTitles, types.Room room) {
    final selectedTag = room.metadata?['Tag'];

    if (isSelected && selectedTag != tagTitles) {
      changeTag.value = tagTitles;
      update();
    }
  }

  Future<void> updateCommunity(types.Room room) async {
    try {
      CustomLoadingIndicator.customLoading();

      // Initialize variables for new values
      String newName = updatedTextEditing.value;
      String newTag = changeTag.value;
      String? newImageUrl;

      // Check if a new image is selected
      if (changeImage.value.path.isNotEmpty) {
        final pic = await DBServiceForStoringOnline.saveProfilePicInStorage(
          File(changeImage.value.path),
          AuthService.currentUser!.uid,
          path: 'group_pic',
        );
        newImageUrl = pic.toString();
      }

      // Check if any of the values have changed
      if (newName != room.name) {
        // Update only the name
        await DBServiceForStoringOnline()
            .updateRoom(room: room, newName: newName);
      }

      if (newTag != room.metadata?['Tag']) {
        // Update only the tag
        await DBServiceForStoringOnline()
            .updateRoom(room: room, newTag: newTag);
      }

      if (newImageUrl != null) {
        // Update only the image URL
        await DBServiceForStoringOnline()
            .updateRoom(room: room, imageUrl: newImageUrl);
      }
      // Retrieve the latest room data from the database
      updatedRoom =
          await DBServiceForStoringOnline.getUpdatedRoomDataAsFuture(room);

      // Closing Loading
      Get.back();
    } catch (e) {
      Get.back();
      log('Error showing while updating room: $e');
    }
  }

  ///<><><><><><><><><><> Ui Logic <><><><><><><><><><><><>

  Widget buildImageSection(types.Room room) {
    return room.imageUrl != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: changeImage.value.path.isNotEmpty
                ? Image.file(
                    changeImage.value,
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    imageUrl: room.imageUrl.toString(),
                    fit: BoxFit.cover,
                  ),
          )
        : Icon(
            Icons.camera_alt_rounded,
            color: AppColors.primaryColor,
          );
  }

  Widget buildTagSectionLogic(types.Room room, int i) {
    final tagTitles = AppConst.tagNames[i];
    final tagColor = AppUtils.getColorBasedOnTag(tagTitles);
    final iconName = AppUtils.getIconNameBasedOnTag(tagTitles);
    final String? selectedTag = room.metadata?['Tag'];
    final bool isSelected = changeTag.value == tagTitles ||
        (changeTag.value.isEmpty &&
            selectedTag != null &&
            selectedTag == tagTitles);
    return AddCommunityWidget.buildTagsContainer(
      iconName: iconName,
      tagTitle: tagTitles,
      tagColor: tagColor,
      isSelected: isSelected,
      onSelect: (val) {
        isTagSelected(val && !isSelected, i, tagTitles, room);
      },
    );
  }
}
