import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:horaz/screens/ChatScreen/ChatUserProfileScreen/ChatUserProfileController.dart';
import 'package:horaz/screens/HomeScreen/export.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:horaz/utils/AppUtils.dart';

class ChatUserProfileScreen extends GetView<ChatUserProfileController> {
  const ChatUserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final types.Room room = Get.arguments[0];
    final Map<String, dynamic> metaData = Get.arguments[1];
    return Scaffold(
      backgroundColor: AppColors.primaryLightColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios_rounded, size: 30),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              onTap: () {
                Get.toNamed(
                  AppRoutes.profileQrScreen,
                  arguments: metaData,
                );
              },
              child:
                  AppUtils.svgToIcon(iconPath: 'qrcode-icon.svg', height: 30),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: SizedBox(
              width: double.infinity,
              child: controller.currentUser?.photoURL != null
                  ? CachedNetworkImage(
                      imageUrl: room.imageUrl.toString(),
                      fit: BoxFit.cover,
                    )
                  : Container(), // Placeholder if user image is not available
            ),
          ),
          Container(
            height: 260,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
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
                CommonWidget.buildCustomText(
                  text: room.name.toString(),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                CommonWidget.buildCustomText(
                  text: AppUtils.formatLastSeenDateTime(room.updatedAt!),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      color: Colors.grey),
                ),
                const SizedBox(height: 40),
                CommonWidget.buildCustomText(
                  text: '+91 ${metaData['metadata']['phoneNumber']}',
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                CommonWidget.buildCustomText(
                  text: 'Phone number',
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      color: Colors.grey),
                ),
                const SizedBox(height: 20),
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
                      color: Colors.grey),
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
            isToggled: true,
            onNotificationTap: (){},
          ),
          const SizedBox(height: 8),
          CommonWidget.buildCustomListProfileTile(
            color: const Color(0xffF98C3E),
            iconData: Icons.notifications_outlined,
            title: 'Notification',
            onTap: () {},
            isToggled: true,
            onNotificationTap: (){},
          ),
        ],
      ),
    );
  }
}
