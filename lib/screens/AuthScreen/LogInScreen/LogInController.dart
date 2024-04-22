import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:horaz/screens/ChatScreen/chat_export.dart';
import 'package:horaz/service/StreamCallService.dart';
import 'package:logger/logger.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class LogInController extends GetxController {
  final authInstance = AuthService().firebaseAuth;
  final firebaseChatInstance = AuthService().firebaseChatCore;
  late TextEditingController emailTextController;
  late TextEditingController passwordTextController;
  FirebaseMessaging fmessageInstance = FirebaseMessaging.instance;

  @override
  void onInit() {
    super.onInit();
    emailTextController = TextEditingController();
    passwordTextController = TextEditingController();
  }
  @override
  void dispose() {
    super.dispose();
    emailTextController.dispose();
    passwordTextController.dispose();
  }

  Future<void> loginUser() async {
    final String email = emailTextController.text.trim();
    final String password = passwordTextController.text;

    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter both email and password");
    } else {
      try {
        // Show loading dialog
        CustomLoadingIndicator.customLoading();
        final User? loginResult = await AuthService.loginWithFirebase(
          email: email,
          password: password,
        );

        if (loginResult != null) {
          await FirestoreService().getUserData();
          // Closing Loading...
          Get.back();
          Get.offAllNamed(AppRoutes.homeNavigationScreen);
          await APIsServices.addFCMTokenToUser(loginResult.uid);
          AppUtils.saveTokenInSharedPrefAsInt(key: 'LoginSuccessfully', value: 1);
        } else {
          // Closing Loading...
          Get.back();
          Fluttertoast.showToast(
              msg: "Login failed. Please check your credentials.");
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // Closing Loading...
          Get.back();
          Fluttertoast.showToast(msg: 'No user found for that email.');
        } else if (e.code == 'wrong-password') {
          // Closing Loading...
          Get.back();
          Fluttertoast.showToast(msg: 'Wrong password provided for that user.');
        } else if (e.code == 'invalid-credential') {
          // Closing Loading...
          Get.back();
          Fluttertoast.showToast(
              msg: "There's no account with this credentials.");
        } else {
          // Closing Loading...
          Get.back();
          Fluttertoast.showToast(msg: 'Login failed. Please try again.');
        }
      } catch (e) {
        // Closing Loading...
        Get.back();
        Fluttertoast.showToast(msg: "Error during login. Please try again.");
      }
    }
  }

  Future loginWithGoogle() async {
    try {
      // Show loading dialog
      CustomLoadingIndicator.customLoading();
      final User? gUser = await AuthService.loginWithGoogle();
      if (gUser != null) {
        await firebaseChatInstance.createUserInFirestore(
          types.User(
            id: gUser.uid,
            firstName: gUser.displayName,
            imageUrl: gUser.photoURL,
          ),
        );

        // Closing Loading...
        Get.back();
        // Navigate To Screen
        Get.offAllNamed(AppRoutes.authScreen);
      } else {
        // Closing Loading...
        Get.back();
        Fluttertoast.showToast(msg: 'Something Wrong While Login');
        return;
      }
    } catch (e) {
      // Closing Loading...
      Get.back();
      Logger().e('Something goes in Google SignIn $e');
    }
  }
}
