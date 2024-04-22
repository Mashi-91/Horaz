import 'package:get/get.dart';
import 'package:horaz/screens/AddCommunityScreen/AddCommunityController.dart';

class AddCommunityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AddCommunityController());
  }
}
