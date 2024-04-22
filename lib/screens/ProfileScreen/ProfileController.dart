import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:horaz/service/AuthService.dart';
import 'package:http/http.dart' as http;

class ProfileController extends GetxController {
  final currentUser = AuthService().firebaseAuth.currentUser;

  Future removeBg() async {
    final String? imgUrl = currentUser?.photoURL.toString();
    if (imgUrl != null) {
      try {
        // Download the image file as bytes
        http.Response response = await http.get(Uri.parse(imgUrl));
        Uint8List imageBytes = response.bodyBytes;

        // Now you have the image bytes, you can use them as needed
        log('Image bytes: $imageBytes');
      } catch (e) {
        // Handle any errors that may occur during file downloading
        print('Error: $e');
      }
    }
  }
}
