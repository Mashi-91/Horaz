import 'package:get/get.dart';
import 'package:horaz/screens/AuthScreen/SignUpScreen/SignUpController.dart';

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignUpController());
  }
}