import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/constants/AppConst.dart';
import 'package:horaz/screens/AddCommunityScreen/AddCommunityController.dart';
import 'package:horaz/screens/AddCommunityScreen/AddCommunityWidget.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:horaz/screens/AddCommunityScreen/BubbleAnimationForContacts.dart';
import 'package:horaz/widgets/CommonWidgets.dart';

class AddSecondCommunityScreen extends GetView<AddCommunityController> {
  const AddSecondCommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CommonWidget.buildBackButton(size: 22),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
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
                  text: 'New Community',
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    letterSpacing: 0,
                  ),
                ),
                CommonWidget.buildCustomText(
                  text: 'Add community details below',
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 14),
                GetBuilder<AddCommunityController>(
                  builder: (context) => Container(
                    height: 180,
                    width: Get.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: AppColors.whiteColor,
                    ),
                    child: InkWell(
                      onTap: () => controller.pickCommunityProfileImage(),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: controller.communityProfileImage?.path != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.file(
                                  controller.communityProfileImage!,
                                  fit: BoxFit.cover),
                            )
                          : Icon(
                              Icons.camera_alt_rounded,
                              color: AppColors.primaryColor,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AddCommunityWidget.buildTextField(
                  textEditingController: controller.textEditingController,
                ),
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
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: AppConst.tagNames.length,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              separatorBuilder: (context, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final iconNames = AppConst.iconNames[i];
                final tagTitles = AppConst.tagNames[i];
                final tagColors = AppConst.tagColors[i];
                return GetBuilder<AddCommunityController>(
                  builder: (_) {
                    return AddCommunityWidget.buildTagsContainer(
                      iconName: iconNames,
                      tagTitle: tagTitles,
                      tagColor: tagColors,
                      isSelected: i == controller.selectedTagIndex,
                      onSelect: (val) {
                        controller.isTagSelected(val, i, tagTitles);
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: Get.width,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: AppColors.whiteColor,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonWidget.buildCustomText(
                    text: 'Community Member',
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  CommonWidget.buildCustomText(
                    text: "${controller.getSelectedUsers().length} Contacts",
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GetBuilder<AddCommunityController>(
                      builder: (_) => GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                        ),
                        itemCount: controller.getSelectedUsers().length,
                        itemBuilder: (context, i) {
                          final userId = controller.getSelectedUsers()[i];
                          final types.User? user = controller.usersById[userId];
                          final imageUrl = user?.imageUrl;
                          return BubbleAnimation(
                            left: 30,
                            imageSize: 32,
                            imageUrl: imageUrl.toString(),
                            onTap: () {
                              controller.removeSelectedUser(userId);
                            },
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: GetBuilder<AddCommunityController>(builder: (_) {
        return Container(
          child: controller.getSelectedUsers().length > 1
              ? CommonWidget.buildCircleButton(
                  onTap: () {
                    controller.createCommunity();
                  },
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.whiteColor,
                    size: 14,
                  ),
                )
              : null,
        );
      }),
    );
  }
}
