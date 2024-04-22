import 'dart:developer';
import 'dart:ui';

import 'package:horaz/config/AppColors.dart';
import 'package:horaz/models/CallHistoryModel.dart';
import 'package:horaz/screens/CallVideoScreen/CallVideoScreen.dart';
import 'package:horaz/screens/ChatScreen/AnimatedDialog.dart';
import 'package:horaz/screens/ChatScreen/chat_export.dart';
import 'package:horaz/screens/HomeScreen/export.dart';
import 'package:horaz/service/EncryptionService.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:horaz/widgets/GetFileIcon.dart';
import 'package:uuid/uuid.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ChatScreenWidget {
  static PreferredSize buildChatAppBar(types.Room room) {
    final controller = Get.find<ChatController>();
    final isGroupChat = room.users.length == 3;
    final currentUserID = AuthService.currentUser!.uid;
    final otherUsers =
        room.users.where((user) => user.id != currentUserID).toList();
    return PreferredSize(
      preferredSize: const Size.fromHeight(80.0),
      child: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: InkWell(
            onTap: () {
              Get.back(); // Move Get.back() here
            },
            child: const Icon(Icons.arrow_back),
          ),
        ),
        title: Obx(
          () => _buildAppBarListTile(
            onTap: () {
              controller.getUpdatedRoom(room, isGroupChat);
            },
            imageUrl: controller.updatedRoom['imageUrl'] ?? room.imageUrl!,
            title: controller.updatedRoom['name'] ?? room.name!,
            subTitle: controller.isOnline.value
                ? 'Online'
                : AppUtils.formatLastSeenDateTime(room.updatedAt?.toInt() ?? 0),
          ),
        ),
        backgroundColor: AppColors.whiteColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(44.0),
            bottomRight: Radius.circular(44.0),
          ),
        ),
        actions: _buildAppBarActions(isGroupChat, otherUsers, room),
      ),
    );
  }

  static _buildAppBarActions(
      isGroupChat, List<types.User> otherUsers, types.Room room) {
    final controller = Get.find<ChatController>();
    if (!isGroupChat) {
      return [
        CommonWidget.buildZegoCallButton(
          iconPath: 'video-call-icon.svg',
          isVideo: true,
          onPressed: (code, message, p2) {
            DBServiceForStoringOnline.storeDataOnFireStore(
              fireStoreCollectionName: 'contactHistory',
              data: CallHistoryModel(
                id: const Uuid().v4(),
                isGroup: false,
                callerUserData: [controller.currentUser],
                receiverUserData: [otherUsers[0]],
                membersId: [
                  AuthService.currentUser!.uid,
                  otherUsers[0].id,
                ],
              ),
            );
          },
          invitee: [
            ZegoUIKitUser(
              id: otherUsers[0].id,
              name: otherUsers[0].firstName.toString(),
            )
          ],
        ),
        const SizedBox(width: 12),
        CommonWidget.buildZegoCallButton(
          iconPath: 'phone-active-icon.svg',
          isVideo: false,
          onPressed: (code, message, p2) {
            DBServiceForStoringOnline.storeDataOnFireStore(
              fireStoreCollectionName: 'contactHistory',
              data: CallHistoryModel(
                id: const Uuid().v4(),
                isGroup: false,
                callerUserData: [controller.currentUser],
                receiverUserData: [otherUsers[0]],
                membersId: [
                  AuthService.currentUser!.uid,
                  otherUsers[0].id,
                ],
              ),
            );
          },
          invitee: [
            ZegoUIKitUser(
              id: otherUsers[0].id,
              name: otherUsers[0].firstName.toString(),
            )
          ],
        ),
      ];
    } else {
      final zegoUser = otherUsers
          .map((e) => ZegoUIKitUser(id: e.id, name: e.firstName.toString()))
          .toList();
      return [
        CommonWidget.buildZegoCallButton(
          iconPath: 'video-call-icon.svg',
          isVideo: true,
          onPressed: (code, message, p2) async {
            await DBServiceForStoringOnline.storeDataOnFireStore(
              fireStoreCollectionName: 'contactHistory',
              data: CallHistoryModel(
                id: const Uuid().v4(),
                isGroup: true,
                roomId: room.id,
                roomName: room.name,
                roomImage: room.imageUrl,
                roomTag: room.metadata?['Tag'] ?? '',
                callerUserData: [controller.currentUser],
                receiverUserData: otherUsers.map((e) => e).toList(),
                membersId: [
                  AuthService.currentUser!.uid,
                  ...otherUsers.map((user) => user.id),
                ],
              ),
            );
          },
          invitee: zegoUser,
        ),
        const SizedBox(width: 12),
        CommonWidget.buildZegoCallButton(
          iconPath: 'phone-active-icon.svg',
          isVideo: false,
          onPressed: (code, message, p2) {
            DBServiceForStoringOnline.storeDataOnFireStore(
              fireStoreCollectionName: 'contactHistory',
              data: CallHistoryModel(
                id: const Uuid().v4(),
                isGroup: true,
                roomId: room.id,
                roomName: room.name,
                roomImage: room.imageUrl,
                roomTag: room.metadata?['Tag'] ?? '',
                callerUserData: [controller.currentUser],
                receiverUserData: otherUsers.map((e) => e).toList(),
                membersId: [
                  AuthService.currentUser!.uid,
                  ...otherUsers.map((user) => user.id),
                ],
              ),
            );
          },
          invitee: zegoUser,
        ),
      ];
    }
  }

  static ChatTheme buildChatTheme(types.Room room, BuildContext context) {
    final controller = Get.find<ChatController>();
    return DefaultChatTheme(
      backgroundColor: AppColors.primaryLightColor,
      inputBorderRadius: BorderRadius.circular(40),
      primaryColor: AppColors.primaryColor,
      inputMargin:
          const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 20),
      inputPadding: const EdgeInsets.symmetric(vertical: 16),
      inputBackgroundColor: AppColors.whiteColor,
      inputTextColor: AppColors.blackColor,
      inputTextStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      attachmentButtonMargin: EdgeInsets.zero,
      attachmentButtonIcon: CommonWidget.buildCircleButton(
        onTap: () {
          const buttonPosition = Offset(100, 100);
          showDialog(
            context: context,
            barrierColor: Colors.transparent,
            builder: (BuildContext context) {
              return AnimatedDialog(
                buttonPosition: buttonPosition,
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: 220,
                  width: Get.width - 18,
                  child: GridView(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    children: [
                      _buildAttachmentIconButton(
                        onTap: () {
                          Get.back();
                          AppUtils.sendCustomFiles(room, context);
                        },
                        iconName: 'Document',
                      ),
                      _buildAttachmentIconButton(
                        onTap: () {
                          Get.back();
                          controller.openCamera(room);
                        },
                        icon: Icons.camera_enhance_rounded,
                        iconName: 'Camera',
                      ),
                      _buildAttachmentIconButton(
                        onTap: () {
                          Get.back();
                          // controller.handleMediaIsVideoOrImage(context, room);
                        },
                        icon: Icons.photo,
                        iconName: 'Gallery',
                      ),
                      _buildAttachmentIconButton(
                        onTap: () {},
                        icon: Icons.headphones,
                        iconName: 'Audio',
                      ),
                      _buildAttachmentIconButton(
                        onTap: () {},
                        icon: Icons.location_on,
                        iconName: 'Location',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        isIcon: true,
        padding: const EdgeInsets.all(8),
        iconData: Icons.add,
        iconSize: 18,
      ),
    );
  }

  static Widget _buildAttachmentIconButton({
    required VoidCallback onTap,
    dynamic icon,
    required String iconName,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: AppColors.listGradientPurpleColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )),
            child: icon != null
                ? Icon(
                    icon,
                    color: AppColors.whiteColor,
                  )
                : AppUtils.svgToIcon(
                    iconPath: 'document-icon.svg',
                    height: 26,
                  ),
          ),
          CommonWidget.buildCustomText(
            text: iconName,
            textStyle: TextStyle(
              fontWeight: FontWeight.w400,
              color: AppColors.blackColor,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildFileMessageTile({
    required types.FileMessage msgValue,
    required int msgWidth,
  }) {
    final isSent =
        msgValue.author.id == Get.find<ChatController>().currentUser.id;
    return Container(
      width: msgWidth.toDouble(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18)
          .copyWith(left: 20),
      decoration: BoxDecoration(
        color: isSent ? AppColors.primaryColor : AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20).copyWith(
          bottomRight: isSent ? Radius.zero : const Radius.circular(20),
          bottomLeft: isSent ? const Radius.circular(20) : Radius.zero,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isSent
                    ? const Color(0xffF5F4FF)
                    : AppColors.greyColor.withOpacity(0.5),
              ),
              child: GetFileIcon(
                msgValue.name,
                size: 30,
              )),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppUtils.getShortName(msgValue.name),
                  style: TextStyle(
                    color: isSent ? AppColors.whiteColor : AppColors.blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 5,
                ),
                CommonWidget.buildCustomText(
                  text:
                      AppUtils.formatFileSize(msgValue.size.toInt()).toString(),
                  textStyle: TextStyle(
                    color: isSent ? AppColors.whiteColor : AppColors.blackColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildAppBarListTile({
    required Function onTap,
    required String imageUrl,
    required String title,
    required String subTitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ListTile(
        onTap: () => onTap(),
        leading: CommonWidget.buildCircleAvatar(
          imageUrl: imageUrl,
          size: 22,
        ),
        minVerticalPadding: 0,
        contentPadding: EdgeInsets.zero,
        title: CommonWidget.buildCustomText(
          text: title,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: CommonWidget.buildCustomText(
          text: subTitle,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  static Widget buildCustomTextMessageBubble(
      {required types.TextMessage msg, required int msgWidth, bool? showName}) {
    final decrypt = EncryptionService.decryptMessage(msg.text);
    final isSentMessage =
        msg.author.id == Get.find<ChatController>().currentUser.id;
    return Container(
      padding: const EdgeInsets.all(20),
      child: CommonWidget.buildCustomText(
        text: decrypt,
        textStyle: TextStyle(
          color: isSentMessage ? AppColors.whiteColor : AppColors.blackColor,
        ),
      ),
    );
  }
}
