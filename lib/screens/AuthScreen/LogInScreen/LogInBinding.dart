import 'package:get/get.dart';
import 'package:horaz/screens/AuthScreen/LogInScreen/LogInController.dart';
import 'package:horaz/screens/AuthScreen/SignUpScreen/SignUpController.dart';

class LogInBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LogInController());
  }
}