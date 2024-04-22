import 'dart:developer' as dev;
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:horaz/models/CallHistoryModel.dart';
import 'package:horaz/screens/ChatScreen/chat_export.dart';
import 'package:horaz/screens/PhoneScreen/PhoneController.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as type;
import 'package:uuid/uuid.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../config/AppColors.dart';

class PhoneScreenWidget {
  static AppBar buildAppBarSection({EdgeInsets? margin, bool isBack = false}) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: margin ?? const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            isBack
                ? InkWell(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.darkPurple,
                      size: 20,
                    ),
                  )
                : Container(),
            const SizedBox(width: 20),
            CommonWidget.buildCustomText(
              text: 'Call History',
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildEmptyScheduledCallSection() {
    final controller = Get.find<PhoneController>();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonWidget.buildCustomText(
              text: "Community Call",
              textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkPurple,
                fontSize: 16,
              ),
            ),
            InkWell(
              onTap: () {
                if (controller.callHistoryModel.isNotEmpty) {
                } else {
                  Get.toNamed(AppRoutes.addPhoneCallScreen);
                }
              },
              child: controller.callHistoryModel.isNotEmpty
                  ? Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.darkPurple,
                      size: 20,
                    )
                  : Icon(
                      Icons.add_outlined,
                      color: AppColors.darkPurple,
                      size: 20,
                    ),
            )
          ],
        ),
        Center(
          child: CommonWidget.buildCustomText(
            text: 'You have not any\ncommunity call 😢',
            textAlign: TextAlign.center,
            margin: const EdgeInsets.symmetric(vertical: 60),
            textStyle: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildCallHistoryTile() {
    final controller = Get.find<PhoneController>();
    return StreamBuilder(
      stream: controller.getAllContactsFromStore(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CustomLoadingIndicator.customLoadingWithoutDialog();
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return buildEmptyCallSection();
        } else {
          final contactsData = snapshot.data!.docs;
          final singleUserData = contactsData.where((doc) {
            final userData = doc.data();
            final isGroup =
                userData.containsKey('isGroup') ? userData['isGroup'] : false;
            // Return true only if it's not a group (isGroup is false)
            return !isGroup;
          }).toList();

          if (singleUserData.isEmpty) {
            return buildEmptyCallSection();
          }
          return ListView.builder(
            itemCount: singleUserData.length,
            itemBuilder: (context, index) {
              final userData = singleUserData[index].data();
              final callHistoryModel = CallHistoryModel.fromJson(userData);

              // Determine whether the current user is the caller or receiver
              final isCurrentUserCaller =
                  callHistoryModel.callerUserData[0].id ==
                      AuthService.currentUser!.uid;

              // Extract caller and receiver information based on whether the current user is caller or receiver
              final otherUserData = isCurrentUserCaller
                  ? callHistoryModel.receiverUserData[0]
                  : callHistoryModel.callerUserData[0];

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 20)
                    .copyWith(right: 20),
                leading: CommonWidget.buildCircleAvatar(
                  imageUrl: otherUserData.imageUrl ?? '',
                ),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonWidget.buildCustomDivider(color: Colors.blue),
                    const SizedBox(height: 4),
                    CommonWidget.buildCustomText(
                      text: otherUserData.firstName.toString(),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                        fontSize: 14,
                      ),
                    ),
                    CommonWidget.buildCustomText(
                      text:
                          AppUtils.timestampToDate(callHistoryModel.createdAt!),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    )
                  ],
                ),
                trailing: InkWell(
                  onTap: () {
                    CommonWidget.buildZegoCallButton(
                      isVideo: false,
                      invitee: [
                        ZegoUIKitUser(
                          id: otherUserData.id,
                          name: otherUserData.firstName.toString(),
                        ),
                      ],
                      onPressed: (code, message, p2) {
                        DBServiceForStoringOnline.storeDataOnFireStore(
                          fireStoreCollectionName: 'contactHistory',
                          data: DBServiceForStoringOnline.storeDataOnFireStore(
                            fireStoreCollectionName: 'contactHistory',
                            data: CallHistoryModel(
                              id: const Uuid().v4(),
                              isGroup: false,
                              callerUserData: [controller.currentUser],
                              receiverUserData: [otherUserData],
                              membersId: [
                                AuthService.currentUser!.uid,
                                otherUserData.id,
                              ],
                            ),
                          ),
                        );
                      },
                      iconPath: 'phone-icon.svg',
                    );
                  },
                  child: AppUtils.svgToIcon(
                    iconPath: 'phone-icon.svg',
                    color: AppColors.primaryColor,
                    height: 20,
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  static Widget buildEmptyCallSection() {
    return Center(
      child: CommonWidget.buildCustomText(
        text: "Your history call is empty 😭\nClick in here to start a call",
        textAlign: TextAlign.center,
        textStyle: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  static Widget buildScheduledCall() {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.only(top: 4, right: 4),
        color: Colors.transparent,
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16)
                  .copyWith(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
              ),
              height: 130,
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CommonWidget.stackImage(
                        images: [
                          CachedNetworkImageProvider(
                            AuthService.currentUser!.photoURL.toString(),
                          ),
                          CachedNetworkImageProvider(
                            AuthService.currentUser!.photoURL.toString(),
                          ),
                          CachedNetworkImageProvider(
                            AuthService.currentUser!.photoURL.toString(),
                          ),
                        ],
                        height: 42,
                        width: 110,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: CommonWidget.buildCustomText(
                          text: 'Milender',
                          maxLine: 1,
                          textStyle: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackColor,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  CommonWidget.buildCustomText(
                    text: 'Scheduled Call',
                    textStyle: TextStyle(
                      fontSize: 12,
                      color: AppColors.greyColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: AppColors.primaryLightColor,
                    ),
                    child: CommonWidget.buildCustomText(
                      text: 'Jun 23 2021, 04.50 am',
                      textStyle: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0,
                        color: AppColors.greyColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              right: 0,
              child: InkWell(
                onTap: () {},
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 8,
                    backgroundColor: Color(0xff857FB4),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  static Widget buildCommunityScheduledCall() {
    final controller = Get.find<PhoneController>();
    return StreamBuilder(
        stream: controller.getAllContactsFromStore(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.docs == null) {
            return buildEmptyScheduledCallSection();
          }
          final groupUserData = snapshot.data!.docs.where((doc) {
            final userData = doc.data();
            final isGroup =
                userData.containsKey('isGroup') ? userData['isGroup'] : false;
            // Return true only if it's not a group (isGroup is false)
            return isGroup;
          }).toList();
          if (snapshot.hasData && groupUserData.isNotEmpty) {
            controller.setCallHistoryModel(
                groupUserData.map((e) => e.data()).toList().obs);
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonWidget.buildCustomText(
                      text: "Community Call",
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkPurple,
                        fontSize: 16,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (snapshot.data!.docs.isNotEmpty) {
                          Get.toNamed(AppRoutes.phoneListCommunityScreen,
                              arguments: controller.callHistoryModel);
                        } else {
                          Get.toNamed(AppRoutes.addPhoneCallScreen);
                        }
                      },
                      child: snapshot.data!.docs.isNotEmpty
                          ? Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: AppColors.darkPurple,
                              size: 20,
                            )
                          : Icon(
                              Icons.add_outlined,
                              color: AppColors.darkPurple,
                              size: 20,
                            ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                      itemCount: min(2, groupUserData.length),
                      itemBuilder: (context, i) {
                        final userData = groupUserData[i].data();
                        final members = CallHistoryModel.fromJson(userData);
                        final tagColor = AppUtils.getColorBasedOnTag(
                            members.roomTag.toString());
                        return buildCommunityHistoryTile(
                          members: members,
                          tagColor: tagColor,
                          groupData: groupUserData,
                        );
                      }),
                ),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomLoadingIndicator.customLoadingWithoutDialog();
          } else {
            return buildEmptyScheduledCallSection();
          }
        });
  }

  static Widget buildCommunityHistoryTile({
    required CallHistoryModel members,
    required tagColor,
    required groupData,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 0, right: 4),
      color: Colors.transparent,
      child: Stack(
        children: [
          Container(
            width: 220,
            height: 130,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14)
                .copyWith(bottom: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              color: AppColors.whiteColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: members.roomImage.toString(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonWidget.buildCustomDivider(color: tagColor),
                        CommonWidget.buildCustomText(
                          text: members.roomName.toString(),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CommonWidget.buildCustomText(
                  text: 'Scheduled on',
                  textStyle: TextStyle(
                    fontSize: 12,
                    color: AppColors.greyColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: AppColors.primaryLightColor,
                  ),
                  child: CommonWidget.buildCustomText(
                    text: AppUtils.timestampToDate(members.createdAt!.toInt()),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    textStyle: TextStyle(
                      fontSize: 9,
                      letterSpacing: 0,
                      color: AppColors.greyColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: groupData.length <= 1 ? 74 : 0,
            child: InkWell(
              onTap: () {
                Get.find<PhoneController>()
                    .deleteContact(members.id.toString());
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 8,
                  backgroundColor: Color(0xff857FB4),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
