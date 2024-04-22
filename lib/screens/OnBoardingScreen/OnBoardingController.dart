import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:horaz/config/AppRoutes.dart';
import 'package:horaz/utils/AppUtils.dart';

class OnBoardingController extends GetxController {
  RxInt currentPageIndex = 0.obs;
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void changePage(var val) {
    currentPageIndex.value = val;
  }

  void goBack() {
    pageController.previousPage(
        duration: const Duration(milliseconds: 600), curve: Curves.ease);
  }

  void skipButton(){
    Get.offAllNamed(AppRoutes.logInScreen);
    AppUtils.saveTokenInSharedPrefAsInt(key: 'ONBOARDINGTOKEN', value: 1);
  }

  Future<void> nextPage() async {
    if (currentPageIndex >= 2) {
      Get.offAllNamed(AppRoutes.logInScreen);
      await AppUtils.saveTokenInSharedPrefAsInt(key: 'ONBOARDINGTOKEN', value: 1);
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.ease,
    );
  }
}
