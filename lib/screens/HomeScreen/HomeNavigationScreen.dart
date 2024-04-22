import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:get/get.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/screens/HomeScreen/HomeController.dart';
import 'package:horaz/screens/HomeScreen/HomeScreenWidget.dart';
import 'package:sizer/sizer.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class HomeNavigationScreen extends GetView<HomeController> {
  const HomeNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdropColor: AppColors.primaryColor,
      childDecoration: BoxDecoration(borderRadius: BorderRadius.circular(40)),
      openRatio: 0.55,
      controller: controller.drawerController,
      animationController: controller.animationStatusSubscription,
      drawer: HomeScreenWidget.buildHomeDrawer(),
      child: Obx(
            () =>
            Scaffold(
              extendBody: true,
              backgroundColor: AppColors.primaryLightColor,
              body: IndexedStack(
                index: controller.currentIndex.value,
                children: controller.pages,
              ),
              bottomNavigationBar: Container(
                margin: EdgeInsets.symmetric(horizontal: 6.w).copyWith(),
                padding: EdgeInsets.only(top: 1.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryLightColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: StylishBottomBar(
                  items: [
                    HomeScreenWidget.buildNavigationItem(
                      activeIconName: 'message-active-icon.svg',
                      iconName: 'message-icon.svg',
                    ),
                    HomeScreenWidget.buildNavigationItem(
                      activeIconName: 'slider-active-icon.svg',
                      iconName: 'slider-icon.svg',
                    ),
                    HomeScreenWidget.buildNavigationItem(
                      activeIconName: 'phone-active-icon.svg',
                      iconName: 'phone-icon.svg',
                    ),
                  ],
                  backgroundColor: AppColors.primaryLightColor,
                  elevation: 0,
                  onTap: (val) => controller.onChangeIndex(RxInt(val)),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  currentIndex: controller.currentIndex.value,
                  option: AnimatedBarOptions(
                    iconStyle: IconStyle.simple,
                  ),
                ),
              ),
              floatingActionButton: controller.buildFloatingActionButton(),
              floatingActionButtonLocation: FloatingActionButtonLocation
                  .endFloat,
            ),
      ),
    );
  }
}
