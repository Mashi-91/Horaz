import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/constants/AppConst.dart';
import 'package:horaz/screens/AddCommunityScreen/BubbleAnimationForContacts.dart';
import 'package:horaz/screens/AddCommunityScreen/AddCommunityController.dart';
import 'package:horaz/screens/AddCommunityScreen/CommunityProfileScreen/CommunityProfileController.dart';
import 'package:horaz/screens/AddCommunityScreen/AddCommunityWidget.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:horaz/screens/AddCommunityScreen/EditCommunityScreen/EditCommunityController.dart';
import 'package:horaz/widgets/CommonWidgets.dart';

class EditCommunityScreen extends GetView<EditCommunityController> {
  const EditCommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final types.Room room = Get.arguments;
    return PopScope(
      canPop: false,
      onPopInvoked: (val) {
        if (val) return;
        Get.back(result: controller.updatedRoom);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: InkWell(
            onTap: () => Get.back(result: controller.updatedRoom),
            child: const Icon(Icons.arrow_back_ios_rounded, size: 22),
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonWidget.buildCustomText(
                    text: 'Edit Community',
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      letterSpacing: 0,
                    ),
                  ),
                  CommonWidget.buildCustomText(
                    text: 'Edit community details below',
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 180,
                    width: Get.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: AppColors.whiteColor,
                    ),
                    child: Obx(
                      () => InkWell(
                        onTap: () {
                          controller.changeImageFunc();
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: controller.buildImageSection(room),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AddCommunityWidget.buildTextField(
                      initialValue: room.name,
                      onChanged: (val) {
                        controller.updateTextEditingFunc(val);
                      }),
                  const SizedBox(height: 8),
                  CommonWidget.buildCustomText(
                    text: 'Choose Tag',
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: Get.width,
              height: 46,
              child: GetBuilder<EditCommunityController>(builder: (_) {
                return ListView.separated(
                  controller: controller.scrollController,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: AppConst.tagNames.length,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  separatorBuilder: (context, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    return controller.buildTagSectionLogic(room, i);
                  },
                );
              }),
            ),
          ],
        ),
        floatingActionButton: Obx(
          () => Container(
            child: controller.changeTag.value.isNotEmpty ||
                    controller.changeImage.value.path.isNotEmpty ||
                    controller.updatedTextEditing.value.isNotEmpty
                ? CommonWidget.buildCircleButton(
                    onTap: () async {
                      await controller.updateCommunity(room);
                    },
                    isIcon: false,
                    child: Icon(
                      Icons.done_rounded,
                      color: AppColors.whiteColor,
                      size: 14,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
