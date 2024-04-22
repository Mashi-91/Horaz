import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:get/get.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/screens/AuthScreen/SignUpScreen/SignUpController.dart';

class SignUpWidget {
  static Widget buildProfilePicSection() {
    final controller = Get.find<SignUpController>();
    return GetBuilder<SignUpController>(builder: (_) {
      return InkWell(
        borderRadius: BorderRadius.circular(80),
        onTap: () {
          controller.profileImagePicker();
        },
        child: CircleAvatar(
          radius: 80,
          backgroundColor: AppColors.primaryLightColor,
          backgroundImage: controller.pickImage != null
              ? FileImage(controller.pickImage!)
              : null,
          child: controller.pickImage == null
              ? Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.primaryColor,
                  size: 28,
                )
              : null,
        ),
      );
    });
  }
}
