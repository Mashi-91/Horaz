import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:horaz/service/AuthService.dart';
import 'package:horaz/utils/AppUtils.dart';

class SearchScreenController extends GetxController {
  var changeText = '';
  var allRooms = <types.Room>[]; // Store all rooms temporarily
  var filteredRooms = <types.Room>[].obs; // Observable list for filtered rooms
  var isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRooms();
  }

  void onChangeText(val) {
    changeText = val;
    if (val.isEmpty) {
      // If search query is empty, clear filtered rooms and reset input text
      filteredRooms.clear();
      isSearching.value = false; // Update search state
    } else {
      // Filter rooms based on search query
      filterRoomsFunc(val.toLowerCase());
      isSearching.value = true; // Update search state
    }
    update();
  }

  void fetchRooms() {
    getSingleRoom().listen((List<types.Room> fetchedRooms) {
      // Update the rooms list with fetched rooms
      allRooms.addAll(fetchedRooms);
    });
  }

  void filterRoomsFunc(String query) {
    filteredRooms.clear(); // Clear previous results
    if (query.isEmpty) {
      // If search query is empty, show all rooms
      filteredRooms.assignAll(allRooms);
    } else {
      // Filter rooms based on search query
      filteredRooms.addAll(
        allRooms.where((room) => room.name!.toLowerCase().contains(query)),
      );
    }
  }

  Stream<List<types.Room>> getSingleRoom() {
    return AuthService().firebaseChatCore.rooms().map((rooms) {
      // Filter the rooms based on the condition that the room has more than two user IDs
      final filteredRooms = rooms.where((room) => room.users.length != 3).toList();
      return filteredRooms;
    });
  }
}
