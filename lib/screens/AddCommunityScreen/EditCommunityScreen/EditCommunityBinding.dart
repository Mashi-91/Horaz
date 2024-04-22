import 'package:get/get.dart';
import 'package:horaz/screens/AddCommunityScreen/EditCommunityScreen/EditCommunityController.dart';

class EditCommunityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EditCommunityController());
  }

}