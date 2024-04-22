import 'package:get/get.dart';
import 'package:horaz/screens/PhoneScreen/AddPhoneCallScreen/AddPhoneCallController.dart';

class AddPhoneCallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AddPhoneCallController());
  }

}