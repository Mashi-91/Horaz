import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/screens/PhoneScreen/PhoneController.dart';
import 'package:horaz/screens/PhoneScreen/PhoneScreenWidget.dart';
import 'package:horaz/widgets/CommonWidgets.dart';

class PhoneScreen extends GetView<PhoneController> {
  const PhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: PhoneScreenWidget.buildAppBarSection(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PhoneScreenWidget.buildCommunityScheduledCall(),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Container(
              width: Get.width,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: PhoneScreenWidget.buildCallHistoryTile(),
            ),
          )
        ],
      ),
    );
  }
}
