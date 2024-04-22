import 'dart:developer';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:horaz/service/AuthService.dart';
import 'package:horaz/service/DBService.dart';
import 'package:horaz/utils/FlutterToast.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static void handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      FlutterToastMsg.flutterToastMSG(msg: 'Access to contact data denied');
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      FlutterToastMsg.flutterToastMSG(
          msg: 'Contact data not available on the device');
    }
  }

  static Future<void> getNotificationPermission() async {
    await FirebaseMessaging.instance.requestPermission().then((value) async {
      await getNotificationChannel();
    });
  }

  static Future<void> getNotificationChannel() async {
    // var result = await FlutterNotificationChannel.registerNotificationChannel(
    //   description: 'For Showing Chats Notification',
    //   id: 'chats',
    //   importance: NotificationImportance.IMPORTANCE_HIGH,
    //   name: 'Chats',
    // );
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'chats',
          channelName: 'Chats',
          channelDescription: "For Showing Chats Notification",
        ),
      ],
    );
  }

  static Future<void> requestContactPermission() async {
    PermissionStatus permissionStatus = await Permission.contacts.request();
    if (permissionStatus != PermissionStatus.granted) {
      handleInvalidPermissions(permissionStatus);
    }
  }


  static Future<void> setOptimalDisplayMode() async {
    final List<DisplayMode> supported = await FlutterDisplayMode.supported;
    final DisplayMode active = await FlutterDisplayMode.active;

    final List<DisplayMode> sameResolution = supported
        .where((DisplayMode m) =>
            m.width == active.width && m.height == active.height)
        .toList()
      ..sort((DisplayMode a, DisplayMode b) =>
          b.refreshRate.compareTo(a.refreshRate));

    final DisplayMode mostOptimalMode =
        sameResolution.isNotEmpty ? sameResolution.first : active;

    /// This setting is per session.
    /// Please ensure this was placed with `initState` of your root widget.
    await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
  }
}
