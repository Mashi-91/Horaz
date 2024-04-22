import 'package:get/get.dart';
import 'package:horaz/screens/OnBoardingScreen/OnBoardingController.dart';

class OnBoardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OnBoardingController());
  }
}