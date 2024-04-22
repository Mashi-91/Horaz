import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/screens/OnBoardingScreen/OnBoardingController.dart';
import 'package:horaz/screens/OnBoardingScreen/OnBoardingScreenWidget.dart';
import 'package:horaz/widgets/CommonWidgets.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends GetView<OnBoardingController> {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          OnBoardingScreenWidget.skipButton(
              onTap: () => controller.skipButton()),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: controller.pageController,
              onPageChanged: (val) => controller.changePage(val),
              children: [
                OnBoardingScreenWidget.pages(
                  image: 'OnBoarding-1.svg',
                  firstText: 'Easy chat with your friends',
                  imageHeight: 210,
                  imageMargin: const EdgeInsets.symmetric(horizontal: 18),
                  textMargin: const EdgeInsets.symmetric(horizontal: 30),
                ),
                OnBoardingScreenWidget.pages(
                  image: 'OnBoarding-2.svg',
                  imageHeight: 250,
                  imageMargin: const EdgeInsets.symmetric(horizontal: 18),
                  firstText: 'Video call with your community',
                  textMargin: const EdgeInsets.symmetric(horizontal: 30),
                ),
                OnBoardingScreenWidget.pages(
                  image: 'OnBoarding-3.svg',
                  imageHeight: 260,
                  imageMargin: const EdgeInsets.symmetric(horizontal: 18),
                  firstText: 'Get notified when someone chat you',
                  textMargin: const EdgeInsets.symmetric(horizontal: 30),
                )
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 22).copyWith(bottom: 34),
            child: Obx(() {
              return Row(
                children: [
                  if (controller.currentPageIndex.value > 0)
                    CommonWidget.buildCircleButton(
                      onTap: () => controller.goBack(),
                      iconColor: AppColors.primaryColor,
                      bgColor: AppColors.primaryColor.withOpacity(0.2),
                      isGradient: false,
                      iconData: Icons.arrow_back_ios_rounded,
                    ),
                  const Spacer(),
                  SmoothPageIndicator(
                    controller: controller.pageController,
                    count: 3,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 12,
                      activeDotColor: AppColors.primaryColor,
                      dotColor: AppColors.greyColor.withOpacity(0.3),
                    ),
                  ),
                  const Spacer(),
                  CommonWidget.buildCircleButton(
                    onTap: () => controller.nextPage(),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
