import 'package:get/get.dart';
import 'package:horaz/screens/OnBoardingScreen/OnBoardingController.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    // final prefs = await SharedPreferences.getInstance();
    // if (prefs.getBool('IsFirstTime') ?? false) {
    //   // Get.put(AuthController());
    // } else {
    //   // Get.put(OnBoardingController());
    // }
  }
}
