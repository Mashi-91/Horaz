import 'package:get/get.dart';
import 'package:horaz/screens/SearchScreen/SearchScreenController.dart';

class SearchScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchScreenController());
  }

}