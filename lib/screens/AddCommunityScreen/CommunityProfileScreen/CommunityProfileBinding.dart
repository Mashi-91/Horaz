import 'package:get/get.dart';
import 'package:horaz/screens/AddCommunityScreen/CommunityProfileScreen/CommunityProfileController.dart';

class CommunityProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CommunityProfileController());
  }
}
