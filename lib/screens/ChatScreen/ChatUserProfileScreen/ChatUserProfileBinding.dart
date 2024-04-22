import 'package:get/get.dart';
import 'package:horaz/screens/ChatScreen/ChatUserProfileScreen/ChatUserProfileController.dart';

class ChatUserProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatUserProfileController());
  }
}
