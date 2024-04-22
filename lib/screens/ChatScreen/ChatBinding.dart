import 'package:get/get.dart';
import 'package:horaz/screens/ChatScreen/ChatController.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatController());
  }
}
