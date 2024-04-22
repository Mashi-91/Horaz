import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:horaz/config/AppRoutes.dart';

class CommunityProfileController extends GetxController {
  RxBool isNotificationToggle = false.obs;
  RxMap updatedRoom = {}.obs;

  types.User convertFirebaseUserToChatUser(User firebaseUser) {
    return types.User(
      id: firebaseUser.uid,
      firstName: firebaseUser.displayName ?? '',
      imageUrl: firebaseUser.photoURL ?? '',
      lastName: '',
    );
  }

  types.User get currentUser =>
      convertFirebaseUserToChatUser(FirebaseAuth.instance.currentUser!);

  void isNotificationToggleFunc() {
    isNotificationToggle.value = !isNotificationToggle.value;
  }

  Future getUpdatedRoom(types.Room room) async {
    final result = await Get.toNamed(
      AppRoutes.editCommunityScreen,
      arguments: room,
    );
    updatedRoom.value = result;
    update();
  }
}
