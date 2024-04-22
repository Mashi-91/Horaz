import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:get/get.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/screens/AuthScreen/SignUpScreen/SignUpController.dart';
import 'package:horaz/screens/AuthScreen/SignUpScreen/SignUpWidget.dart';
import 'package:horaz/widgets/CommonWidgets.dart';
import 'package:sizer/sizer.dart';

class SignUpScreen extends GetView<SignUpController> {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 30).copyWith(top: 8.h),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SignUpWidget.buildProfilePicSection(),
                  SizedBox(height: 6.h),
                  CommonWidget.buildCustomTextField(
                    hintText: "Name",
                    controller: controller.nameTextController,
                    keyboardType: TextInputType.name,
                    keyboardAction: TextInputAction.next,
                  ),
                  SizedBox(height: 1.8.h),
                  CommonWidget.buildCustomTextField(
                    hintText: "Email",
                    keyboardType: TextInputType.visiblePassword,
                    controller: controller.emailTextController,
                    keyboardAction: TextInputAction.next,
                  ),
                  SizedBox(height: 1.8.h),
                  CommonWidget.buildCustomTextField(
                    hintText: "Phone number",
                    keyboardType: const TextInputType.numberWithOptions(),
                    controller: controller.phoneNumberTextController,
                    keyboardAction: TextInputAction.next,
                  ),
                  SizedBox(height: 1.8.h),
                  CommonWidget.buildCustomTextField(
                    hintText: "Password",
                    keyboardType: TextInputType.visiblePassword,
                    obsecure: true,
                    controller: controller.passwordTextController,
                    keyboardAction: TextInputAction.done,
                  ),
                  SizedBox(height: 3.h),
                  CommonWidget.buildCircleButton(
                    onTap: () {
                      controller.createUserAccount();
                    },
                  ),
                  SizedBox(height: 4.4.h),
                  RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: CommonWidget.buildCustomText(
                            text: 'Already a member? ',
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        WidgetSpan(
                          child: InkWell(
                            onTap: () => Get.back(),
                            child: CommonWidget.buildCustomText(
                              text: 'Log In',
                              textStyle: TextStyle(
                                fontSize: 13,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
