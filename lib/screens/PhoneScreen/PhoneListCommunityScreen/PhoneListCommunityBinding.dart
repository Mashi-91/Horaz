import 'package:get/get.dart';
import 'package:horaz/screens/PhoneScreen/PhoneListCommunityScreen/PhoneListCommunityController.dart';

class PhoneListCommunityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PhoneListCommunityController());
  }

}