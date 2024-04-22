import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:horaz/screens/StoryScreen/StoryController.dart';
import 'package:horaz/screens/StoryScreen/StoryScreenWidget.dart';
import 'package:horaz/utils/AppUtils.dart';
import 'package:horaz/widgets/CommonWidgets.dart';
import 'package:sizer/sizer.dart';

class StoryScreen extends GetView<StoryController> {
  const StoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: StoryScreenWidget.buildAppBarSection(),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonWidget.buildCustomText(
                    text: 'My Story',
                    margin: const EdgeInsets.only(left: 30),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  StoryScreenWidget.buildMyStorySection(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: Get.width,
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: StoryScreenWidget.buildStoryGridView(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
