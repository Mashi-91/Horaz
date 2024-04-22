import 'package:get/get.dart';
import 'package:horaz/screens/HomeScreen/CommunityListScreen/CommunityListController.dart';

class CommunityListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CommunityListController());
  }
}