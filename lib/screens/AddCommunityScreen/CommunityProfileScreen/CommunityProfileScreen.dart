import 'dart:developer';
import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/screens/AddCommunityScreen/CommunityProfileScreen/CommunityProfileController.dart';
import 'package:horaz/screens/AddCommunityScreen/AddCommunityWidget.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:horaz/service/AuthService.dart';
import 'package:horaz/utils/AppUtils.dart';
import 'package:horaz/widgets/CommonWidgets.dart';

class CommunityProfileScreen extends GetView<CommunityProfileController> {
  const CommunityProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final types.Room room = Get.arguments[0];
    return PopScope(
      canPop: false,
      onPopInvoked: (val){
        if(val) return;
        Get.back(result: controller.updatedRoom);
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryLightColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: InkWell(
            onTap: () => Get.back(result: room),
            child: const Icon(Icons.arrow_back_ios_rounded, size: 30),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () async {
                  await controller.getUpdatedRoom(room);
                },
                child: const Icon(
                  Icons.edit_outlined,
                  size: 32,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: InkWell(
                onTap: () async {
                  // Get.toNamed(
                  //   AppRoutes.profileQrScreen,
                  //   arguments: metaData,
                  // );
                },
                child:
                    AppUtils.svgToIcon(iconPath: 'qrcode-icon.svg', height: 30),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Obx(
                    () => SizedBox(
                      height: Get.height * 0.5,
                      width: double.infinity,
                      child: AuthService.currentUser?.photoURL != null
                          ? CachedNetworkImage(
                              imageUrl: controller.updatedRoom['imageUrl'] ??
                                  room.imageUrl.toString(),
                              fit: BoxFit.cover,
                            )
                          : Container(), // Placeholder if user image is not available
                    ),
                  ),
                  Obx(
                    () => Positioned(
                      bottom: 20,
                      left: 20,
                      child: AddCommunityWidget.buildTagsContainer(
                        iconName: AppUtils.getIconNameBasedOnTag(
                            controller.updatedRoom['Tag'] ??
                                room.metadata?['Tag']),
                        tagTitle: controller.updatedRoom['Tag'] ??
                            room.metadata?['Tag'],
                        tagColor: AppUtils.getColorBasedOnTag(
                            controller.updatedRoom['Tag'] ??
                                room.metadata?['Tag']),
                        verticalPadding: 16,
                        horizontalPadding: 14,
                        isSelected: false,
                        onSelect: (val) {},
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: Get.width,
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20)
                    .copyWith(bottom: 30),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(60),
                    bottomLeft: Radius.circular(60),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => CommonWidget.buildCustomText(
                        text: controller.updatedRoom['name'] ??
                            room.name.toString(),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    CommonWidget.buildCustomText(
                      text: AppUtils.formatLastSeenDateTime(room.updatedAt!),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 40),
                    CommonWidget.buildCustomText(
                      text: 'A young fresh minded UI Designer',
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    CommonWidget.buildCustomText(
                      text: 'Description',
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
              ),
              CommonWidget.buildCustomListProfileTile(
                color: const Color(0xffFFB200),
                iconData: Icons.bookmark_outline_rounded,
                title: 'Saved Messages',
                onTap: () {},
                isTopPadding: true,
                isToggled: false,
                onNotificationTap: () {},
              ),
              const SizedBox(height: 8),
              Obx(
                () => CommonWidget.buildCustomListProfileTile(
                  color: const Color(0xffF98C3E),
                  iconData: Icons.notifications_outlined,
                  title: 'Notification',
                  onTap: () {},
                  isLastIcon: false,
                  isToggled: controller.isNotificationToggle.value,
                  onNotificationTap: () => controller.isNotificationToggleFunc(),
                ),
              ),
              AddCommunityWidget.buildMemberTile(room),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                itemCount: room.users.length,
                separatorBuilder: (context, i) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final users = room.users[i];
                  final isCurrentUser = users.id == AuthService.currentUser!.uid;
                  return CommonWidget.buildContactTile(
                    user: users,
                    onTap: () {},
                    isCurrentUser: isCurrentUser,
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
