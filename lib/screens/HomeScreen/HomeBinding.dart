import 'package:get/get.dart';
import 'package:horaz/screens/HomeScreen/HomeController.dart';
import 'package:horaz/screens/PhoneScreen/PhoneController.dart';
import 'package:horaz/screens/StoryScreen/StoryController.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController(),permanent: true);
    Get.lazyPut(() => StoryController());
    Get.lazyPut(() => PhoneController());
  }
}
