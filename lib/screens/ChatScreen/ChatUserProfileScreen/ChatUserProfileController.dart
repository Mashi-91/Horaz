import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:horaz/service/AuthService.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatUserProfileController extends GetxController {
  final currentUser = AuthService().firebaseAuth.currentUser;
  Map<String, dynamic> metaData = {};

  @override
  Future<void> onInit() async {
    super.onInit();
  }
}
