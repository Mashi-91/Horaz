import 'dart:convert';
import 'dart:developer';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:horaz/service/AuthService.dart';
import 'package:horaz/service/DBService.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class ChooseContactController extends GetxController {
  final firebaseChatInstance = AuthService().firebaseChatCore;
  List<Contact> loadedContacts = [];
  final ScrollController scrollController = ScrollController();
  int offset = 0;
  int limit = 80;
  bool loading = false;


  @override
  Future<void> onInit() async {
    super.onInit();
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

  void sendMessageToUser(ChooseContactController controller, types.User user) {
    // Create a partial text message
    const types.PartialText(
      text: "Hello, let's chat!",
    );

    // Send the message to the selected user
    firebaseChatInstance.createRoom(user).then(
      (room) {
        firebaseChatInstance.createRoom(user);
      },
    );
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
