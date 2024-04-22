import 'package:get/get.dart';
import 'package:horaz/screens/ProfileQrScreen/PrtofileQrController.dart';

class ProfileQrBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileQrController());
  }
}
