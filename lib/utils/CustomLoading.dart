import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:loading_indicator/loading_indicator.dart';

class CustomLoadingIndicator {
  static customLoading() {
    return Get.dialog(
      Center(
        child: SizedBox(
          height: 50,
          child: LoadingIndicator(
            indicatorType: Indicator.ballRotateChase,
            strokeWidth: 1,
            colors: [
              AppColors.primaryColor,
              Colors.deepPurple,
              Colors.yellow,
              Colors.teal,
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static customLoadingWithoutDialog() {
    return Center(
      child: SizedBox(
        height: 50,
        child: LoadingIndicator(
          indicatorType: Indicator.ballRotateChase,
          strokeWidth: 1,
          colors: [
            AppColors.primaryColor,
            Colors.deepPurple,
            Colors.yellow,
            Colors.teal,
          ],
        ),
      ),
    );
  }
}
