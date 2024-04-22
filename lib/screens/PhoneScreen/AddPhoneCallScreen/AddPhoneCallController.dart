import 'dart:developer';

import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:horaz/service/AuthService.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class AddPhoneCallController extends GetxController {
  final firebaseChatInstance = AuthService().firebaseChatCore;
  List<Contact> loadedContacts = [];
  late ScrollController scrollController;
  int offset = 0;
  int limit = 80;
  bool loading = false;

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


  @override
  Future<void> onInit() async {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
    await loadContactsFunction();
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollListener() async {
    // Check if user has scrolled to the bottom
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      // Load more contacts
      await loadContactsFunction();
      update();
    }
  }


  Future<void> loadContactsFunction({bool forceRefresh = false}) async {
    if (!loading) {
      loading = true;
      if (forceRefresh) {
        // Data doesn't exist in the local database, fetch from ContactsService
        List<Contact> getContactsFromService =
        await ContactsService.getContacts(orderByGivenName: true);
        log(getContactsFromService.length.toString());

        // Save contacts to the local database
        loadedContacts = getContactsFromService;
        offset = limit;
      } else {
        // loadedContacts.addAll(existingContacts);
        log(loadedContacts.length.toString());
        offset += limit;
      }
      loading = false;
    }
  }

  // Fetch the next batch of contacts
  Future<void> fetchNextContacts() async {
    await loadContactsFunction();
  }
}