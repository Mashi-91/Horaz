import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/config/AppRoutes.dart';
import 'package:horaz/screens/ProfileScreen/ProfileController.dart';
import 'package:horaz/service/AuthService.dart';
import 'package:horaz/utils/AppUtils.dart';
import 'package:horaz/widgets/CommonWidgets.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final metadata = Get.arguments;
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
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: (){
                Get.toNamed(AppRoutes.profileQrScreen,arguments: metadata);
              },
              child: AppUtils.svgToIcon(
                iconPath: 'qrcode-icon.svg',
                height: 30,
              ),
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
              child: AuthService().firebaseAuth.currentUser?.photoURL != null
                  ? CachedNetworkImage(
                      imageUrl: AuthService()
                          .firebaseAuth
                          .currentUser!
                          .photoURL
                          .toString(),
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
                  text: controller.currentUser!.displayName.toString(),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                CommonWidget.buildCustomText(
                  text: 'Last seen on yesterday at 11:20pm',
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      color: Colors.grey),
                ),
                const SizedBox(height: 40),
                CommonWidget.buildCustomText(
                  text: '+91${metadata?['metadata']?['phoneNumber'] ?? ''}',
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
          _customListHomeTile(
            color: const Color(0xffFFB200),
            iconData: Icons.bookmark_outline_rounded,
            title: 'Saved Messages',
            onTap: () {},
            isTopPadding: true,
          ),
          const SizedBox(height: 8),
          _customListHomeTile(
            color: const Color(0xffF98C3E),
            iconData: Icons.notifications_outlined,
            title: 'Notification',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _customListHomeTile({
    required Color color,
    required IconData iconData,
    required String title,
    required Function onTap,
    bool isTopPadding = false,
    bool isLastIcon = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26)
          .copyWith(bottom: 14, top: isTopPadding ? 20 : 0),
      child: InkWell(
        onTap: () => onTap(),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(iconData, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            CommonWidget.buildCustomText(
              text: title,
              textStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            if (isLastIcon)
              const Icon(Icons.arrow_forward_ios_rounded, size: 14)
          ],
        ),
      ),
    );
  }
}
