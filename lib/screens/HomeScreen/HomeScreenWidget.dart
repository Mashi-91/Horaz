import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:horaz/constants/emoji-icon.dart';
import 'package:horaz/main.dart';
import 'package:horaz/screens/ChatScreen/chat_export.dart';
import 'package:horaz/screens/HomeScreen/export.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:horaz/service/EncryptionService.dart';
import 'package:horaz/widgets/CustomToggleButton.dart';
import 'package:stylish_bottom_bar/model/bar_items.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class HomeScreenWidget {
  static AppBar buildAppBarSection() {
    final controller = Get.find<HomeController>();
    return AppBar(
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Obx(
        () => Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: AnimatedOpacity(
            opacity:
                controller.animationStatus.value == AnimationStatus.completed
                    ? 0.0
                    : 1.0,
            duration: const Duration(milliseconds: 500),
            // Adjust duration as needed
            child: Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundImage: controller.currentUser?.photoURL != null
                      ? CachedNetworkImageProvider(
                          controller.currentUser!.photoURL.toString(),
                        )
                      : null,
                  child: controller.currentUser?.photoURL == null
                      ? AppUtils.svgToIcon(
                          iconPath: 'empty-profile-icon.svg', height: 44)
                      : null,
                ),
                SizedBox(width: 4.w),
                CommonWidget.buildCustomText(
                  text: controller.currentUser?.displayName.toString() ?? '',
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkPurple,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Get.toNamed(AppRoutes.searchScreen);
                  },
                  child: AppUtils.svgToIcon(
                    iconPath: 'search-icons.svg',
                    height: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildEmptyCommunitySection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonWidget.buildCustomText(
              text: "Community",
              textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkPurple,
                fontSize: 18,
              ),
            ),
            InkWell(
              onTap: () {
                Get.toNamed(AppRoutes.addCommunityScreen);
              },
              child: Icon(
                Icons.add_outlined,
                color: AppColors.darkPurple,
                size: 20,
              ),
            )
          ],
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.center,
          child: CommonWidget.buildCustomText(
            text: 'You are not member of\ncommunity yet 😢',
            textAlign: TextAlign.center,
            textStyle: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  static Widget dialogContent(BuildContext context, types.Room room) {
    return Hero(
      tag: room.id,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Material(
          elevation: 0,
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: Get.width * 0.04),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    // height: Get.height * 0.4,
                    padding: EdgeInsets.only(bottom: Get.height * 0.02),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          offset: Offset(0.0, 10.0),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: Get.height * 0.29,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                room.imageUrl.toString(),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: Get.height * 0.04),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: Get.height * 0.03),
                          child: CommonWidget.buildCustomText(
                            text: room.name.toString(),
                            textStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Get.height * 0.020),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: CustomToggleButton(
                          isToggled: false,
                          onTap: () {},
                        ),
                      ),
                      Flexible(
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.whiteColor,
                            child: AppUtils.svgToIcon(
                              iconPath: 'message-active-icon.svg',
                              height: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildChatListTile({
    required String imageUrl,
    required String title,
    required Widget subTitle,
    required String timeStamp,
    required String readMSG,
    required Function onTap,
    required Function onAvtarTap,
    required String heroTag,
  }) {
    DateTime timestamp = DateTime.parse("2024-02-02 11:37:28");
    String formattedTime = AppUtils.formatTimestampForAgo(timestamp);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ListTile(
        onTap: () => onTap(),
        leading: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () => onAvtarTap(),
          child: Hero(
            tag: heroTag, // Assign hero tag
            child: CommonWidget.buildCircleAvatar(
              imageUrl: imageUrl,
            ),
          ),
        ),
        title: CommonWidget.buildCustomText(
          text: title,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: subTitle,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonWidget.buildCustomText(
              text: formattedTime,
              textStyle: TextStyle(
                fontWeight: FontWeight.w400,
                color: AppColors.greyColor,
                fontSize: 10,
              ),
            ),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            //   decoration: BoxDecoration(
            //     color: AppColors.redColor,
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: CommonWidget.buildCustomText(
            //     text: readMSG,
            //     textAlign: TextAlign.center,
            //     textStyle: TextStyle(
            //       fontWeight: FontWeight.w400,
            //       color: AppColors.whiteColor,
            //       fontSize: 10,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  static Widget buildSubTitle(dynamic lastMessage) {
    if (lastMessage != null) {
      if (lastMessage is types.ImageMessage) {
        // If the last message is an image, show 'image' as subtitle
        return const Align(
          alignment: Alignment.centerLeft,
          child: Icon(Icons.image, size: 18),
        );
      } else if (lastMessage is types.TextMessage) {
        // If the last message is a text message, show its text as subtitle
        final decrypt = EncryptionService.decryptMessage(lastMessage.text);
        return CommonWidget.buildCustomText(
          text: decrypt,
          textStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.blackColor.withOpacity(0.7),
            letterSpacing: 0,
            fontSize: 12,
            overflow: TextOverflow.ellipsis,
          ),
        );
      } else if (lastMessage is types.FileMessage) {
        return Align(
          alignment: Alignment.centerLeft,
          child: AppUtils.svgIconInString(Emojione.file_folder),
        );
      } else if (lastMessage is types.VideoMessage) {
        return Align(
          alignment: Alignment.centerLeft,
          child: AppUtils.svgIconInString(Emojione.videocassette),
        );
      }
    }
    // Return an empty container if there's no last message or it's not supported
    return Container();
  }

  static Widget buildEmptyConversationSection() {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: CommonWidget.buildCustomText(
        text:
            'You have no conversation yet 😭\nClick in here to start a conversation',
        textAlign: TextAlign.center,
        textStyle: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  static BottomBarItem buildNavigationItem({
    required String activeIconName,
    required String iconName,
  }) {
    return BottomBarItem(
      icon: AppUtils.svgToIcon(
        iconPath: iconName,
      ),
      selectedIcon: AppUtils.svgToIcon(
        iconPath: activeIconName,
      ),
      title: const Text(''),
    );
  }

  static Widget buildHomeDrawer() {
    final controller = Get.find<HomeController>();
    final metadata = globalMetaData;
    return Padding(
      padding: const EdgeInsets.only(left: 30, top: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AuthService.currentUser?.photoURL != null
                ? CachedNetworkImageProvider(
                    AuthService.currentUser!.photoURL.toString())
                : null,
            child: AuthService.currentUser?.photoURL == null
                ? AppUtils.svgToIcon(
                    iconPath: 'empty-profile-icon.svg', height: 44)
                : null,
          ),
          const SizedBox(height: 10),
          CommonWidget.buildCustomText(
            text:
                AuthService.currentUser?.displayName ?? metadata?['firstName'],
            textStyle: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.whiteColor,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          CommonWidget.buildCustomText(
            text: metadata?['metadata'] != null
                ? '+91${metadata?['metadata']['phoneNumber']}'
                : '',
            textStyle: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.whiteColor,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 70),
          Column(
            children: [
              _customListHomeTile(
                color: const Color(0xff31C6EE),
                iconData: Icons.person_outline,
                title: 'My Profile',
                onTap: () {
                  controller.drawerController.hideDrawer();
                  Get.toNamed(AppRoutes.profileScreen, arguments: metadata);
                },
              ),
              _customListHomeTile(
                color: const Color(0xff3CE3B1),
                iconData: Icons.contacts,
                title: 'Contact',
                onTap: () {
                  controller.drawerController.hideDrawer();
                  Get.toNamed(AppRoutes.chooseContactScreen);
                },
              ),
              _customListHomeTile(
                color: const Color(0xffFFB200),
                iconData: Icons.bookmark_outline_rounded,
                title: 'Saved Messages',
                onTap: () {},
              ),
              const SizedBox(height: 30),
              _customListHomeTile(
                color: const Color(0xffF98C3E),
                iconData: Icons.notifications_outlined,
                title: 'Notification',
                onTap: () {},
              ),
              // _customListHomeTile(
              //   color: const Color(0xff9852F6),
              //   iconData: Icons.settings,
              //   title: 'Setting',
              //   onTap: () {},
              // ),
              const SizedBox(height: 40),
              _customListHomeTile(
                color: const Color(0xffF93888),
                iconData: Icons.logout_rounded,
                title: 'Logout',
                onTap: () {
                  controller.drawerController.hideDrawer();
                  AuthService().firebaseAuth.signOut().then((value) {
                    ZegoUIKitPrebuiltCallInvitationService().uninit();
                    Get.offAllNamed(AppRoutes.logInScreen);
                    AppUtils.saveTokenInSharedPrefAsInt(
                        key: "LoginSuccessfully", value: 0);
                  });
                  if (GoogleSignIn().currentUser != null) {
                    GoogleSignIn().signOut();
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  static Widget _customListHomeTile({
    required Color color,
    required IconData iconData,
    required String title,
    required Function onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () => onTap(),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(iconData, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            CommonWidget.buildCustomText(
              text: title,
              textStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.whiteColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildSingleRoomSection() {
    final controller = Get.find<HomeController>();
    return StreamBuilder<List<types.Room>>(
      stream: controller.getSingleRoom(),
      initialData: controller.singleRoom,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CustomLoadingIndicator.customLoadingWithoutDialog();
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          // Clear previous data
          controller.singleRoom.clear();
          controller.singleRoom.addAll(snapshot.data!);
          return ListView.builder(
            itemCount: controller.singleRoom.length,
            itemBuilder: (context, i) {
              final types.Room room = controller.singleRoom[i];
              // Check if someone is typing
              bool isTyping = FirestoreService().isUserTyping(room);
              // Check if there are any last messages
              final dynamic lastMessage = room.lastMessages?.isNotEmpty ?? false
                  ? room.lastMessages!.last
                  : null;

              return HomeScreenWidget.buildChatListTile(
                imageUrl: room.imageUrl.toString(),
                title: room.name.toString(),
                subTitle: isTyping
                    ? CommonWidget.buildCustomText(
                        text: 'typing...',
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : HomeScreenWidget.buildSubTitle(lastMessage),
                timeStamp: room.updatedAt.toString(),
                readMSG: room.lastMessages?.length.toString() ?? '',
                onTap: () {
                  Get.toNamed(AppRoutes.chatScreen, arguments: room);
                },
                heroTag: room.id,
                onAvtarTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false,
                      barrierDismissible: true,
                      pageBuilder: (_, __, ___) => Dialog(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        insetPadding: EdgeInsets.zero,
                        child: HomeScreenWidget.dialogContent(context, room),
                      ),
                    ),
                  );
                },
              );
            },
          );
        } else {
          return HomeScreenWidget.buildEmptyConversationSection();
        }
      },
    );
  }

  static Widget buildCommunityRoomSection() {
    final controller = Get.find<HomeController>();

    return StreamBuilder<List<types.Room>>(
      stream: controller.getGroupRoom(),
      initialData: controller.groupRoom,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CustomLoadingIndicator.customLoadingWithoutDialog();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return buildEmptyCommunitySection();
        } else {
          controller.groupRoom.clear();
          controller.groupRoom.addAll(snapshot.data!);
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonWidget.buildCustomText(
                    text: "Community",
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkPurple,
                      fontSize: 18,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (snapshot.data!.isEmpty) {
                        Get.toNamed(AppRoutes.addCommunityScreen);
                      } else {
                        Get.toNamed(AppRoutes.communityListScreen,
                            arguments: snapshot.data);
                      }
                    },
                    child: snapshot.data!.isNotEmpty
                        ? Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.darkPurple,
                            size: 16,
                          )
                        : Icon(
                            Icons.add_outlined,
                            color: AppColors.darkPurple,
                            size: 20,
                          ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 150,
                child: ListView.separated(
                  separatorBuilder: (context, i) => const SizedBox(width: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: min(2, snapshot.data!.length),
                  itemBuilder: (context, index) {
                    final types.Room room = snapshot.data![index];
                    final tagColor =
                        AppUtils.getColorBasedOnTag(room.metadata!['Tag']);
                    final dynamic lastMsg = room.lastMessages?.first ?? '';
                    String lastMsgUserName = '';
                    if (lastMsg != '') {
                      lastMsgUserName = lastMsg.author.firstName ?? '';
                    }
                    return buildCommunityTile(
                      tagColor: tagColor,
                      imageUrl: room.imageUrl.toString(),
                      lastMsg: HomeScreenWidget.buildSubTitle(lastMsg),
                      lastMsgUserName: lastMsgUserName,
                      title: room.name.toString(),
                      users: room.users
                          .map((user) => NetworkImage(user.imageUrl.toString()))
                          .toList(),
                      onTap: () {
                        Get.toNamed(AppRoutes.chatScreen, arguments: room);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  static Widget buildCommunityTile({
    required String imageUrl,
    required Color tagColor,
    required String title,
    required List<ImageProvider<Object>> users,
    String? lastMsgUserName,
    required Widget lastMsg,
    required Function onTap,
  }) {
    return InkWell(
      onTap: () => onTap(),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: AppColors.whiteColor,
        ),
        child: Column(
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
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 3,
                      width: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        color: tagColor,
                      ),
                    ),
                    CommonWidget.buildCustomText(
                      text: title,
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
            const SizedBox(height: 10),
            if (lastMsgUserName != null || lastMsgUserName != '')
              Row(
                children: [
                  CommonWidget.buildCustomText(
                    text: lastMsgUserName!,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor,
                      fontSize: 14,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 120,
                    child: lastMsg,
                  )
                ],
              ),
            const SizedBox(height: 10),
            CommonWidget.stackImage(images: users),
          ],
        ),
      ),
    );
  }
}
