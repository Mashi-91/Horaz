import 'package:get/get.dart';
import 'package:horaz/service/AuthService.dart';
import 'package:share_plus/share_plus.dart';

class ProfileQrController extends GetxController {
  final currentUser = AuthService().firebaseAuth.currentUser;

  Future<void> shareContact() async {
    final metaData = Get.arguments;
    final displayName = currentUser!.displayName;
    await Share.share(
      'Check Horaz Chatting App \n Name: $displayName \n EmailAddress: ${metaData['email']} \n PhoneNumber: ${metaData['phoneNumber']}',
      subject: 'My Horaz Info',
    );
  }
}
