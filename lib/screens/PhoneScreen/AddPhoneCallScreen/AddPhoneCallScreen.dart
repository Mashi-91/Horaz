import 'dart:developer';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:get/get.dart';
import 'package:horaz/config/AppRoutes.dart';
import 'package:horaz/models/CallHistoryModel.dart';
import 'package:horaz/screens/PhoneScreen/AddPhoneCallScreen/AddPhoneCallController.dart';
import 'package:horaz/screens/ChooseContactScreen/ChooseContactWidget.dart';
import 'package:horaz/service/AuthService.dart';
import 'package:horaz/service/DBService.dart';
import 'package:horaz/service/FireStoreService.dart';
import 'package:horaz/utils/AppUtils.dart';
import 'package:horaz/utils/CustomLoading.dart';
import 'package:horaz/widgets/CommonWidgets.dart';
import 'package:uuid/uuid.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class AddPhoneCallScreen extends GetView<AddPhoneCallController> {
  const AddPhoneCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: InkWell(
              onTap: () async {
                Get.back();
                Get.toNamed(AppRoutes.searchScreen);
              },
              child: AppUtils.svgToIcon(
                iconPath: 'search-icons.svg',
                height: 20,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonWidget.buildCustomText(
              text: 'All Contacts',
              textStyle: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
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
                      userSnapshot.data!.isNotEmpty) {
                    final users = userSnapshot.data!;
                    final contacts = controller.loadedContacts;
                    return GetBuilder<AddPhoneCallController>(builder: (_) {
                      return ListView.separated(
                        controller: controller.scrollController,
                        separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                        itemCount: users.length + contacts.length,
                        itemBuilder: (context, index) {
                          if (index < users.length) {
                            final types.User user = users[index];
                            return CommonWidget.buildContactTile(
                              user: user,
                              isTrailingIcon: true,
                              trailingIconTap: (){
                                CommonWidget.buildZegoCallButton(
                                  isVideo: false,
                                  invitee: [
                                    ZegoUIKitUser(
                                      id: user.id,
                                      name: user.firstName.toString(),
                                    ),
                                  ],
                                  onPressed: (code, message, p2) async {
                                    Get.back();
                                    await DBServiceForStoringOnline.storeDataOnFireStore(
                                      fireStoreCollectionName: 'contactHistory',
                                      data: DBServiceForStoringOnline.storeDataOnFireStore(
                                        fireStoreCollectionName: 'contactHistory',
                                        data: CallHistoryModel(
                                          id: const Uuid().v4(),
                                          isGroup: false,
                                          callerUserData: [controller.currentUser],
                                          receiverUserData: [user],
                                          membersId: [
                                            AuthService.currentUser!.uid,
                                            user.id,
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  iconPath: 'phone-icon.svg',
                                );
                              },
                              onTap: () {
                              },
                            );
                          } else {
                            final Contact contact =
                            contacts[index - users.length];
                            return ChooseContactWidget
                                .buildContactListTileForContact(contact);
                          }
                        },
                      );
                    });
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
    );
  }
}
