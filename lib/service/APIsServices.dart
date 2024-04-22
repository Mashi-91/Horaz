import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:horaz/config/ApiKeys.dart';
import 'package:horaz/screens/ChatScreen/chat_export.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class APIsServices {

  static Future<void> sendPushNotification({
    required User user,
    required String nToken,
    required String msg,
  }) async {
    try {
      final body = {
        'to': nToken,
        'notification': {
          'title': user.displayName,
          'body': msg,
          "android_channel_id": "chats",
          'sound': 'default',
        },
        "data": {
          "some_data": "User Id: ${user.uid}",
        },
        "priority": "high",
        "content_available": true,
      };
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'key=${ApiKeys.firebaseServerKey}',
        },
        body: jsonEncode(body),
      );

      Logger().i("Response Body ${response.body}");
    } catch (e) {
      Logger().e('Error While Sending Notification $e');
    }
  }

  static Future<void> addFCMTokenToUser(String currentUserUid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(currentUserUid);

      final userData = await userDoc.get();
      final metadata = userData.data()?['metadata'] ?? {};

      metadata['notification_token'] = token;

      await userDoc.update({'metadata': metadata});

      FirebaseMessaging.onMessage.listen((event) {
        log('Message data ${event.data}');

        if (event.notification != null) {
          log('Message also contained a notification: ${event.notification}');
        }
      });
    } catch (e) {
      log('Error adding FCM token to user: $e');
    }
  }


  }
