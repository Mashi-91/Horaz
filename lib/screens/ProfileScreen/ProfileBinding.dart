import 'package:get/get.dart';
import 'package:horaz/screens/ProfileScreen/ProfileController.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileController());
  }
}
