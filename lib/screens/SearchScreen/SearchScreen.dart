import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/screens/ChatScreen/chat_export.dart';
import 'package:horaz/screens/HomeScreen/export.dart';
import 'package:horaz/screens/SearchScreen/SearchScreenController.dart';
import 'package:horaz/utils/AppUtils.dart';

class SearchScreen extends GetView<SearchScreenController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _searchTextField(
          onChange: (val) {
            controller.onChangeText(val);
          },
        ),
      ),
      body: Obx(() {
        if (!controller.isSearching.value) {
          // If the user is not searching, show an initial message or UI
          return Center(
            child: CommonWidget.buildCustomText(
              text: 'Try to Search',
              textStyle: TextStyle(fontSize: 12, color: AppColors.blackColor),
            ),
          );
        } else if (controller.filteredRooms.isEmpty) {
          // If the user is searching but no results are found, show a message
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: CommonWidget.buildCustomText(
                    text: 'No result Found',
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 18),
                    margin: const EdgeInsets.symmetric(horizontal: 24)
                        .copyWith(top: 12),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CommonWidget.buildCustomText(
                        text: '0 Result found 😭',
                        textStyle: TextStyle(
                            fontSize: 12, color: AppColors.blackColor),
                      ),
                      CommonWidget.buildCustomText(
                        text: 'Try to search by another words or text',
                        textStyle: TextStyle(
                            fontSize: 12, color: AppColors.blackColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          // If the user is searching and results are found, display the filtered rooms
          return Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonWidget.buildCustomText(
                  text: 'Found ${controller.filteredRooms.length} Results',
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 24)
                      .copyWith(top: 12),
                  separatorBuilder: (context, i) => const SizedBox(height: 10),
                  itemCount: controller.filteredRooms.length,
                  itemBuilder: (context, index) {
                    final room = controller.filteredRooms[index];
                    final otherUser = room.users.firstWhere(
                        (user) => user.id != AuthService.currentUser!.uid);
                    return CommonWidget.buildContactTile(
                      user: otherUser,
                      onTap: () {
                        // Going back to homeScreen
                        Get.back();
                        // Navigate to ChatScreen
                        Get.toNamed(AppRoutes.chatScreen, arguments: room);
                      },
                      radius: 24,
                    );
                  },
                ),
              ],
            ),
          );
        }
      }),
    );
  }

  Widget _searchTextField({required Function(String val) onChange}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CommonWidget.buildBackButton(size: 24),
        const SizedBox(width: 14),
        Expanded(
          child: SizedBox(
            height: 50,
            child: TextFormField(
              onChanged: (val) => onChange(val),
              keyboardType: TextInputType.text,
              cursorHeight: 16,
              style: const TextStyle(height: 1.0),
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: AppColors.whiteColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: AppColors.whiteColor),
                ),
                hintText: 'Search something',
                hintStyle: TextStyle(fontSize: 12, color: AppColors.greyColor),
                border: InputBorder.none,
                filled: true,
                fillColor: AppColors.whiteColor,
                suffixIconConstraints: const BoxConstraints(maxHeight: 18),
                suffixIcon: AppUtils.svgToIcon(
                  iconPath: 'search-icons.svg',
                  margin: const EdgeInsets.only(right: 18),
                  height: 18,
                ),
                contentPadding: const EdgeInsets.fromLTRB(20, 10.0, 12.0, 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
