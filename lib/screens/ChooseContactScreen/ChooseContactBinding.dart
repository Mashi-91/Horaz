import 'package:get/get.dart';
import 'package:horaz/screens/ChooseContactScreen/ChooseContactController.dart';

class ChooseContactBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChooseContactController());
  }
}
