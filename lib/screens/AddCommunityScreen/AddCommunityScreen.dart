import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:get/get.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/config/AppRoutes.dart';
import 'package:horaz/screens/AddCommunityScreen/AddCommunityController.dart';
import 'package:horaz/screens/AddCommunityScreen/BubbleAnimationForContacts.dart';
import 'package:horaz/service/FireStoreService.dart';
import 'package:horaz/utils/AppUtils.dart';
import 'package:horaz/utils/CustomLoading.dart';
import 'package:horaz/widgets/CommonWidgets.dart';

class AddCommunityScreen extends GetView<AddCommunityController> {
  const AddCommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CommonWidget.buildBackButton(size: 22),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: InkWell(
              onTap: () {},
              child: AppUtils.svgToIcon(
                iconPath: 'search-icons.svg',
                height: 20,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonWidget.buildCustomText(
              text: 'New Community',
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                letterSpacing: 0,
              ),
            ),
            CommonWidget.buildCustomText(
              text: 'Choose up to to 1000 contacts',
              textStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                letterSpacing: 0,
              ),
            ),
            GetBuilder<AddCommunityController>(builder: (_) {
              if (_.getSelectedUsers().isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.only(
                      top: controller.getSelectedUsers().isNotEmpty ? 24 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonWidget.buildCustomText(
                        text: 'Choosed Contacts',
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(
                          width: Get.width,
                          height: 50,
                          child: ListView.separated(
                            separatorBuilder: (context, val) =>
                                const SizedBox(width: 12),
                            scrollDirection: Axis.horizontal,
                            itemCount: _.getSelectedUsers().length,
                            itemBuilder: (context, index) {
                              final selectedUserId =
                                  _.getSelectedUsers()[index];
                              final selectedUser = _.usersById[selectedUserId];
                              return BubbleAnimation(
                                imageUrl: selectedUser?.imageUrl.toString(),
                                onTap: () {
                                  controller.removeSelectedUser(selectedUserId);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Container(); // or any other widget you prefer
              }
            }),
            const SizedBox(height: 30),
            CommonWidget.buildCustomText(
              text: 'All Contacts',
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: FutureBuilder<List<types.User>>(
                future: FirestoreService.getUsers(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return CustomLoadingIndicator.customLoadingWithoutDialog();
                  } else if (userSnapshot.hasError) {
                    return Center(
                      child: Text('Error loading users: ${userSnapshot.error}'),
                    );
                  } else if (userSnapshot.hasData &&
                      userSnapshot.data != null) {
                    final users = userSnapshot.data!;
                    return GetBuilder<AddCommunityController>(
                      builder: (_) {
                        return ListView.separated(
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final types.User user = users[index];
                            final isSelected =
                                controller.usersById.containsKey(user.id);
                            return CommonWidget.buildContactTile(
                              user: user,
                              onTap: () {
                                controller.toggleUserSelection(
                                    user, isSelected);
                              },
                              isSelected: isSelected,
                            );
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('No users available'),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GetBuilder<AddCommunityController>(builder: (_) {
        return Container(
          child: controller.getSelectedUsers().length > 1
              ? CommonWidget.buildCircleButton(
                  onTap: () {
                    Get.toNamed(AppRoutes.addSecondCommunityScreen);
                  },
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.whiteColor,
                    size: 14,
                  ),
                )
              : null,
        );
      }),
    );
  }
}
