import 'dart:developer';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:horaz/service/AuthService.dart';
import 'package:horaz/service/EncryptionService.dart';
import 'package:horaz/utils/AppUtils.dart';
import 'package:horaz/widgets/CommonWidgets.dart';
import 'package:horaz/widgets/GetFileIcon.dart';
import 'package:horaz/widgets/VideoPlayerWidget.dart';
import 'package:path/path.dart';

class CustomChatBubble extends StatelessWidget {
  final bool isSent;
  final dynamic msg;
  final Offset position;
  final types.Room room;

  CustomChatBubble({
    required this.isSent,
    required this.msg,
    required this.position,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return buildChatBubble(context);
  }

  Widget buildChatBubble(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    double maxTopMargin = screenSize.height -
        position.dy -
        200; // Adjust 200 based on your chat bubble height

    // Clamp topMargin value to ensure it's within bounds
    double topMargin = position.dy;
    if (position.dy > maxTopMargin) {
      topMargin = maxTopMargin;
    } else if (position.dy < 0) {
      topMargin = 0;
    }

    BorderRadius borderRadius;
    if (isSent) {
      borderRadius = const BorderRadius.only(
        topRight: Radius.circular(17),
        topLeft: Radius.circular(17),
        bottomLeft: Radius.circular(17),
      );
    } else {
      borderRadius = const BorderRadius.only(
        topRight: Radius.circular(17),
        topLeft: Radius.circular(17),
        bottomRight: Radius.circular(17),
      );
    }

    if (msg is types.TextMessage) {
      return buildTextMessageSection(borderRadius, context, topMargin);
    } else if (msg is types.ImageMessage) {
      return buildImageMessageSection(borderRadius, topMargin);
    } else if (msg is types.VideoMessage) {
      return buildVideoMessageSection(borderRadius, topMargin);
    } else if (msg is types.FileMessage) {
      return buildFileMessageSection(borderRadius, topMargin);
    } else {
      return const SizedBox(); // Handle other message types if needed
    }
  }

  Widget buildFileMessageSection(BorderRadius borderRadius, double topMargin) {
    return Container(
      alignment: isSent ? Alignment.topRight : Alignment.topLeft,
      margin: EdgeInsets.only(
        left: isSent ? 100.0 : 0.0,
        right: isSent ? 0.0 : 100.0,
        top: topMargin,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Row(
          mainAxisAlignment:
              isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment:
                  isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  width: 200,
                  // margin: EdgeInsets.only(
                  //     right: isSent ? 10 : 0, left: isSent ? 0 : 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 18)
                          .copyWith(left: 20),
                  decoration: BoxDecoration(
                    color:
                        isSent ? AppColors.primaryColor : AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomRight:
                          isSent ? Radius.zero : const Radius.circular(20),
                      bottomLeft:
                          isSent ? const Radius.circular(20) : Radius.zero,
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
                            msg.name,
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
                              AppUtils.getShortName(msg.name),
                              style: TextStyle(
                                color: isSent
                                    ? AppColors.whiteColor
                                    : AppColors.blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 5,
                            ),
                            CommonWidget.buildCustomText(
                              text: AppUtils.formatFileSize(msg.size.toInt())
                                  .toString(),
                              textStyle: TextStyle(
                                color: isSent
                                    ? AppColors.whiteColor
                                    : AppColors.blackColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  width: 150,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Material(
                      color: isSent ? AppColors.primaryColor : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CommonWidget.chatBubbleOption(
                            iconData: Icons.reply_rounded,
                            title: 'Reply',
                            onTap: () {},
                            isSent: isSent,
                          ),
                          if (isSent)
                            ListTile(
                              onTap: () async {
                                await AuthService()
                                    .firebaseChatCore
                                    .deleteMessage(room.id, msg.id)
                                    .then((value) => Get.back());
                              },
                              leading: Icon(Icons.delete_outline_rounded,
                                  color: AppColors.redColor),
                              title: CommonWidget.buildCustomText(
                                text: 'Delete',
                                textStyle: TextStyle(
                                  color: AppColors.redColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextMessageSection(
      BorderRadius borderRadius, BuildContext context, double topMargin) {
    final decrypt = EncryptionService.decryptMessage(msg.text);
    return Container(
      alignment: isSent ? Alignment.topRight : Alignment.topLeft,
      margin: EdgeInsets.only(
        left: isSent ? 100.0 : 0.0,
        right: isSent ? 0.0 : 100.0,
        top: topMargin,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Row(
          mainAxisAlignment:
              isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment:
                  isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSent ? AppColors.primaryColor : Colors.white,
                    borderRadius: borderRadius,
                  ),
                  child: Text(
                    decrypt ?? '',
                    style: TextStyle(
                      color:
                          isSent ? AppColors.whiteColor : AppColors.blackColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  width: 150,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Material(
                      color: isSent ? AppColors.primaryColor : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CommonWidget.chatBubbleOption(
                            iconData: Icons.reply_rounded,
                            title: 'Reply',
                            onTap: () {},
                            isSent: isSent,
                          ),
                          CommonWidget.chatBubbleOption(
                            iconData: Icons.copy_rounded,
                            title: 'Copy',
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: msg.text));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Message copied'),
                              ));
                            },
                            isSent: isSent,
                          ),
                          if (isSent)
                            ListTile(
                              onTap: () async {
                                await AuthService()
                                    .firebaseChatCore
                                    .deleteMessage(room.id, msg.id)
                                    .then((value) => Get.back());
                              },
                              leading: Icon(Icons.delete_outline_rounded,
                                  color: AppColors.redColor),
                              title: CommonWidget.buildCustomText(
                                text: 'Delete',
                                textStyle: TextStyle(
                                  color: AppColors.redColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageMessageSection(BorderRadius borderRadius, double topMargin) {
    return Container(
      alignment: isSent ? Alignment.topRight : Alignment.topLeft,
      margin: EdgeInsets.only(
        left: isSent ? 100.0 : 0.0,
        right: isSent ? 0.0 : 100.0,
        top: topMargin,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Row(
          mainAxisAlignment:
              isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment:
                  isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: msg.uri,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                    ),
                    child: ClipRRect(
                      borderRadius: borderRadius,
                      child: CachedNetworkImage(
                        imageUrl: msg.uri ?? '',
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  width: 150,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Material(
                      color: isSent ? AppColors.primaryColor : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CommonWidget.chatBubbleOption(
                            iconData: Icons.reply_rounded,
                            title: 'Reply',
                            onTap: () {},
                            isSent: isSent,
                          ),
                          if (isSent)
                            ListTile(
                              onTap: () async {
                                await AuthService()
                                    .firebaseChatCore
                                    .deleteMessage(room.id, msg.id)
                                    .then((value) => Get.back());
                              },
                              leading: Icon(Icons.delete_outline_rounded,
                                  color: AppColors.redColor),
                              title: CommonWidget.buildCustomText(
                                text: 'Delete',
                                textStyle: TextStyle(
                                  color: AppColors.redColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVideoMessageSection(BorderRadius borderRadius, double topMargin) {
    return Container(
      height: 200,
      width: 200,
      alignment: isSent ? Alignment.topRight : Alignment.topLeft,
      margin: EdgeInsets.only(
        left: isSent ? 100.0 : 0.0,
        right: isSent ? 0.0 : 100.0,
        top: topMargin,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Row(
          mainAxisAlignment:
              isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                    ),
                    child: ClipRRect(
                      borderRadius: borderRadius,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxWidth: 200, maxHeight: 200), // Adjust as needed
                        child: VideoViewPage(
                          path: msg.uri ?? '',
                          isFullScreen: false,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    width: 150,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Material(
                        color: isSent ? AppColors.primaryColor : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CommonWidget.chatBubbleOption(
                              iconData: Icons.reply_rounded,
                              title: 'Reply',
                              onTap: () {},
                              isSent: isSent,
                            ),
                            if (isSent)
                              ListTile(
                                onTap: () async {
                                  await AuthService()
                                      .firebaseChatCore
                                      .deleteMessage(room.id, msg.id)
                                      .then((value) => Get.back());
                                },
                                leading: Icon(Icons.delete_outline_rounded,
                                    color: AppColors.redColor),
                                title: CommonWidget.buildCustomText(
                                  text: 'Delete',
                                  textStyle: TextStyle(
                                    color: AppColors.redColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
