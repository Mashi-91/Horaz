import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/screens/ChatScreen/chat_export.dart';
import 'package:horaz/screens/HomeScreen/HomeScreen.dart';
import 'package:horaz/screens/PhoneScreen/PhoneScreen.dart';
import 'package:horaz/screens/StoryScreen/StoryScreen.dart';
import 'package:horaz/screens/StoryScreen/StoryScreenWidget.dart';
import 'package:horaz/utils/CameraUtils/CustomCamera.dart';
import 'package:horaz/widgets/AnimatedFloatingButton.dart';

class HomeController extends FullLifeCycleController
    with GetTickerProviderStateMixin, WidgetsBindingObserver {
  final User? currentUser = AuthService().firebaseAuth.currentUser;

  var currentIndex = 0.obs;
  RxBool isDialogVisible = false.obs;

  late AdvancedDrawerController drawerController;
  late AnimationController animationStatusSubscription;
  Rx<AnimationStatus> animationStatus = AnimationStatus.dismissed.obs;

  final List<types.Room> singleRoom = [];
  final List<types.Room> groupRoom = [];

  @override
  Future<void> onInit() async {
    WidgetsBinding.instance.addObserver(this);
    drawerController = AdvancedDrawerController();
    animationStatusSubscription = AnimationController(vsync: this);
    animationStatusSubscription.addStatusListener((val) {
      animationStatus.value = val;
    });
    super.onInit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    drawerController.dispose();
    animationStatusSubscription.dispose();
    super.dispose();
  }

  void onChangeIndex(RxInt val) {
    currentIndex.value = val.value;
    update();
  }

  List<Widget> pages = [
    HomeScreen(),
    StoryScreen(),
    PhoneScreen(),
  ];

  Widget? buildFloatingActionButton() {
    switch (currentIndex.value) {
      case 0:
        return ExpandableFab(
          distance: 112,
          children: [
            ActionButton(
              onPressed: () {
                Get.toNamed(AppRoutes.addCommunityScreen);
              },
              icon: Icon(FluentIcons.people_16_filled,
                  color: AppColors.primaryColor, size: 26),
              bgColor: AppColors.whiteColor,
            ),
            ActionButton(
              onPressed: () {
                Get.toNamed(AppRoutes.chooseContactScreen);
              },
              icon: AppUtils.svgToIcon(iconPath: 'message-active-icon.svg'),
              bgColor: AppColors.whiteColor,
            ),
          ],
        );
      case 1:
        return CommonWidget.buildCircleButton(
          onTap: () {
            Get.to(() => const CustomCamera());
          },
          isIcon: false,
          child: AppUtils.svgToIcon(
            iconPath: 'slider-add-icon.svg',
          ),
          padding: const EdgeInsets.all(20),
          iconSize: 26,
        );
      case 2:
        return CommonWidget.buildCircleButton(
          onTap: () {
            Get.toNamed(AppRoutes.addPhoneCallScreen);
          },
          isIcon: false,
          child: AppUtils.svgToIcon(
            iconPath: 'phone-add-icon.svg',
          ),
          padding: const EdgeInsets.all(20),
          iconSize: 26,
        );
    }
    return null;
  }

  Stream<List<types.Room>> getSingleRoom() {
    return AuthService().firebaseChatCore.rooms().map((rooms) {
      // Filter the rooms based on the condition that the room has more than two user IDs
      final filteredRooms =
          rooms.where((room) => room.users.length != 3).toList();
      return filteredRooms;
    });
  }

  Stream<List<types.Room>> getGroupRoom() {
    return AuthService().firebaseChatCore.rooms().map((rooms) {
      // Filter the rooms based on the condition that the room has more than two user IDs
      final filteredRooms =
          rooms.where((room) => room.users.length > 2).toList();
      return filteredRooms;
    });
  }

  static Stream<DocumentSnapshot> getUserPresenceStream(String userId) {
    return DBServiceForStoringOnline.firestore.doc(userId).snapshots();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
        DBServiceForStoringOnline.setUserOffline(currentUser!.uid);
        break;
      case AppLifecycleState.inactive:
        return;
      case AppLifecycleState.paused:
        DBServiceForStoringOnline.setUserOffline(currentUser!.uid);
        break;
      case AppLifecycleState.resumed:
        DBServiceForStoringOnline.setUserOnline(currentUser!.uid);
        break;
      case AppLifecycleState.hidden:
        return;
    }
  }
}
