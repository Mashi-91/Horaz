import 'dart:developer';
import 'dart:io';

import 'package:crop_image/crop_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:horaz/config/AppRoutes.dart';
import 'package:horaz/service/AuthService.dart';
import 'package:horaz/service/FireStoreService.dart';
import 'package:horaz/utils/CustomLoading.dart';
import 'package:horaz/utils/FlutterToast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

import '../../../utils/AppUtils.dart';

class SignUpController extends GetxController {
  late TextEditingController nameTextController;
  late TextEditingController emailTextController;
  late TextEditingController phoneNumberTextController;
  late TextEditingController passwordTextController;
  final firebaseChatInstance = AuthService().firebaseChatCore;
  File? pickImage;
  final cropController = CropController(
    aspectRatio: 16.0 / 9.0,
    defaultCrop: Rect.fromLTRB(0.05, 0.05, 0.95, 0.95),
  );

  @override
  void onInit() {
    super.onInit();
    nameTextController = TextEditingController();
    emailTextController = TextEditingController();
    phoneNumberTextController = TextEditingController();
    passwordTextController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    nameTextController.dispose();
    emailTextController.dispose();
    phoneNumberTextController.dispose();
    passwordTextController.dispose();
  }

  Future<void> createUserAccount() async {
    final String name = nameTextController.text.trim();
    final String email = emailTextController.text.trim();
    final String phoneNumber = phoneNumberTextController.text.trim();
    final String password = passwordTextController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        phoneNumber.isEmpty ||
        password.isEmpty) {
      FlutterToastMsg.flutterToastMSG(msg: "All fields must be filled");
    } else if (pickImage == null) {
      FlutterToastMsg.flutterToastMSG(msg: "Please select your profile image!");
    } else {
      // Show loading dialog
      CustomLoadingIndicator.customLoading();
      try {
        await AuthService.createAccountWithFirebase(
          email: email,
          password: password,
          phoneNumber: phoneNumber,
          name: name,
          pickImage: pickImage,
        ).then((value) async {
          FirebaseMessaging.onMessage.listen((event) {
            log('Message data ${event.data}');

            if (event.notification != null) {
              log('Message also contained a notification: ${event.notification}');
            }
          });

          await FirestoreService().getUserData();
          // Close loading dialog
          Get.back();
          // Navigate to the authentication screen
          Get.offAllNamed(AppRoutes.homeNavigationScreen);
          AppUtils.saveTokenInSharedPrefAsInt(key: 'LoginSuccessfully', value: 1);
        });
      } on FirebaseAuthException catch (e) {
        // Close loading dialog
        Get.back();
        if (e.code == 'weak-password') {
          FlutterToastMsg.flutterToastMSG(msg: 'Weak password. Try again.');
        } else if (e.code == 'email-already-in-use') {
          FlutterToastMsg.flutterToastMSG(msg: 'Email already in use.');
        } else {
          // Log the error
          Logger().e('Error While Creating Account $e');
          // Show a generic error message
          FlutterToastMsg.flutterToastMSG(
              msg: "Error creating account. Please try again.");
        }
      } catch (e) {
        // Close loading dialog
        Get.back();
        // Log the error
        Logger().e('Unexpected Error While Creating Account $e');
        // Show a generic error message
        FlutterToastMsg.flutterToastMSG(
            msg: "Unexpected error creating account. Please try again.");
      }
    }
  }

  void profileImagePicker() async {
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      cropImage(image.path);
      pickImage = File(image.path);
      update();
    } else {
      log("You didn't choose any picture!");
    }
  }

  void cropImage(String image) {
    if (pickImage != null) {
      CropImage(image: Image.file(File(image)));
    }
  }
}
