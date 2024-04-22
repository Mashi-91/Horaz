import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/config/AppRoutes.dart';
import 'package:horaz/screens/AuthScreen/LogInScreen/LogInController.dart';
import 'package:horaz/widgets/CommonWidgets.dart';
import 'package:sizer/sizer.dart';

class LogInScreen extends GetView<LogInController> {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 30).copyWith(top: 6.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/images/login.svg'),
                SizedBox(height: 4.h),
                CommonWidget.buildCustomText(
                  text: "Welcome back",
                  textStyle: TextStyle(
                    color: AppColors.darkPurple,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                CommonWidget.buildCustomText(
                  text: 'sign in to access your account',
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4.h),
                CommonWidget.buildCustomTextField(
                  hintText: "Email",
                  controller: controller.emailTextController,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 2.h),
                CommonWidget.buildCustomTextField(
                  hintText: "Password",
                  keyboardType: TextInputType.visiblePassword,
                  obsecure: true,
                  controller: controller.passwordTextController,
                ),
                SizedBox(height: 1.h),
                Align(
                  alignment: Alignment.bottomRight,
                  child: InkWell(
                    onTap: () {},
                    child: CommonWidget.buildCustomText(
                        text: 'Forgot password ?',
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryColor,
                        )),
                  ),
                ),
                SizedBox(height: 3.h),
                CommonWidget.buildCircleButton(
                  onTap: () {
                    controller.loginUser();
                  },
                ),
                // SizedBox(height: 2.h),
                // GoogleAuthButton(
                //   onPressed: () {
                //     controller.loginWithGoogle();
                //   },
                //   style: const AuthButtonStyle(
                //     buttonColor: Colors.white,
                //     borderRadius: 10,
                //     buttonType: AuthButtonType.icon,
                //     iconType: AuthIconType.outlined,
                //   ),
                // ),
                SizedBox(height: 3.h),
                RichText(
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                        child: CommonWidget.buildCustomText(
                          text: 'New Member? ',
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      WidgetSpan(
                        child: InkWell(
                          onTap: () {
                            Get.toNamed(AppRoutes.signUpScreen);
                          },
                          child: CommonWidget.buildCustomText(
                            text: 'Register now',
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
    );
  }
}
