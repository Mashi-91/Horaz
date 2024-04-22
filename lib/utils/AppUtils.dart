import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:get/get.dart';
import 'package:horaz/constants/AppConst.dart';
import 'package:horaz/models/ownRoom.dart';
import 'package:horaz/service/AuthService.dart';
import 'package:horaz/service/DBService.dart';
import 'package:horaz/service/FireStoreService.dart';
import 'package:horaz/utils/CustomLoading.dart';
import 'package:horaz/widgets/CommonWidgets.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUtils {

  static Future saveTokenInSharedPrefAsInt(
      {required String key, required int value}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setInt(key, value);
  }

  static Future saveProfileDataToLocalDB(
      {required String key, required List<String> value}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(key, value);
  }

  static Future<int> getTokenInSharedPrefAsInt({required String key}) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(key) ?? 0;
    // log('Value retrieved from SharedPreferences for key $key: $value');
    return value;
  }

  static Future removeTokenInSharedPref({required String key}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  static Widget svgIconInString(String iconName, {double? size = 30}) {
    return SvgPicture.string(
      iconName,
      height: size,
      width: size,
    );
  }

  static Color getColorBasedOnTag(String tag) {
    // Find the index of the tag in the tagNames list
    final index = AppConst.tagNames.indexOf(tag);

    if (index != -1) {
      // Use the index to get the corresponding color from the tagColors list
      return AppConst.tagColors[index];
    } else {
      // Return a default color if the tag is not found
      return Colors.grey;
    }
  }

  static Color generateRandomColor() {
    math.Random random = math.Random();
    final generatedColor =  Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
    return generatedColor;
  }


  static String getIconNameBasedOnTag(String tag) {
    // Find the index of the tag in the tagNames list
    final index = AppConst.tagNames.indexOf(tag);

    if (index != -1 && index < AppConst.iconNames.length) {
      // Use the index to get the corresponding icon name from the iconNames list
      return AppConst.iconNames[index];
    } else {
      // Return a default icon name if the tag is not found or the index is out of bounds
      return 'error'; // You can change this to any default icon name you prefer
    }
  }

  static Widget svgToIcon({
    required String iconPath,
    double? height,
    Color? color,
    EdgeInsets? margin,
  }) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: SvgPicture.asset(
        "assets/icons/$iconPath",
        height: height,
        color: color,
      ),
    );
  }

  /// <><><><><><><><><> For ChatUserProfile <><><><><><><><><>
  static String formatLastSeenDateTime(int timestamp) {
    final DateTime lastSeenDateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    final formatter = DateFormat.jm(); // Time format
    String timeFormatted = formatter.format(lastSeenDateTime);

    if (lastSeenDateTime.isAfter(today)) {
      return 'Last seen today at $timeFormatted';
    } else if (lastSeenDateTime.isAfter(yesterday)) {
      return 'Last seen yesterday at $timeFormatted';
    } else {
      final dateFormat = DateFormat('MMM d');
      final dateFormatted = dateFormat.format(lastSeenDateTime);
      return 'Last seen on $dateFormatted at $timeFormatted';
    }
  }

  static String timestampToDate(int timestamp) {
    // Convert the timestamp to a DateTime object
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    // Define the format of the output date string
    DateFormat outputFormat = DateFormat('MMM dd yyyy, hh.mm a');

    // Format the DateTime object to the desired date string
    String formattedDate = outputFormat.format(dateTime);

    return formattedDate;
  }

  static   Map<String, dynamic> encodeMap(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        // Recursively encode nested maps
        result[key] = encodeMap(value);
      } else if (value is Timestamp) {
        // Convert Timestamp to DateTime
        result[key] = value.toDate().toIso8601String();
      } else if (value is DateTime) {
        // Convert DateTime to ISO 8601 string
        result[key] = value.toIso8601String();
      } else {
        // Use value as is
        result[key] = value;
      }
    });
    return result;
  }

  static Map<String, dynamic> decodeMap(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        // Recursively decode nested maps
        result[key] = decodeMap(value);
      } else if (value is String && value.isNotEmpty) {
        // Check if value is a non-empty string
        try {
          // Try parsing ISO 8601 string to DateTime
          result[key] = DateTime.parse(value);
        } catch (_) {
          // If parsing fails, use value as is
          result[key] = value;
        }
      } else {
        // Use value as is
        result[key] = value;
      }
    });
    return result;
  }


  static String formatTimestampForAgo(DateTime timestamp) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return "${difference.inSeconds}s ago";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else {
      return "${timestamp.hour}.${timestamp.minute}${timestamp.hour < 12 ? 'am' : 'pm'}";
    }
  }

  static Future<Uint8List> urlToUint8List(String pathUrl) async {
    return Uint8List.fromList(pathUrl.codeUnits);
  }

  static Future<File> uint8ListToFile(
      Uint8List uint8List, String filePath) async {
    File file = File(filePath);
    await file.writeAsBytes(uint8List);
    return file;
  }

  static String getShortName(String fileName) {
    // Split the filename by the period (.) to separate the name and extension
    List<String> parts = fileName.split('.');
    if (parts.length > 1) {
      // Get the first part of the filename (name)
      String name = parts.first;
      // Get the last part of the filename (extension)
      String extension = parts.last;
      // Get the first 7 characters of the filename
      String shortName = name.substring(0, 7);
      // Combine the short name and the extension with a hyphen
      return '$shortName.$extension';
    } else {
      // If there's no extension, return the entire filename
      return fileName;
    }
  }

  static String formatFileSize(int sizeInBytes) {
    const int KB = 1024;
    const int MB = 1024 * 1024;

    if (sizeInBytes < KB) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < MB) {
      double sizeInKB = sizeInBytes / KB;
      return '${sizeInKB.toStringAsFixed(2)} KB';
    } else {
      double sizeInMB = sizeInBytes / MB;
      return '${sizeInMB.toStringAsFixed(2)} MB';
    }
  }

  // <><><><>>><><><><><><><><><><><><><> Chat Utils <><><><<><><><><><><><><><><><><><><><><>><

  static Timestamp updatedAtFunc() {
    final DateTime currentTime = DateTime.now();
    return Timestamp.fromMillisecondsSinceEpoch(
        currentTime.millisecondsSinceEpoch);
  }

  static void updateTypingStatus(String roomId, String? userId, bool isTyping) {
    if (userId != null) {
      FirestoreService().setTypingStatus(roomId, userId, isTyping);
    }
  }

  static Future<String?> getNotificationTokenFromUserCollection(
      String typingUserId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(typingUserId)
          .get();

      if (userDoc.exists) {
        final metadata = userDoc.data()?['metadata'];
        if (metadata != null) {
          final token = metadata['notification_token'];
          if (token != null) {
            return token.toString(); // Convert token to string
          } else {
            log('Notification token not found for user: $typingUserId');
            return null;
          }
        } else {
          log('Metadata not found for user: $typingUserId');
          return null;
        }
      } else {
        log('User not found in Firestore: $typingUserId');
        return null;
      }
    } catch (e) {
      log('Error fetching notification token: $e');
      return null;
    }
  }

  static Future<bool> isExecutableFile(String filePath) async {
    final file = File(filePath);
    final List<int> bytes = await file.readAsBytes();
    if (bytes.length >= 2 && bytes[0] == 0x4D && bytes[1] == 0x5A) {
      // File has MZ header, indicating it's an executable file (Windows)
      return true;
    }
    return false;
  }

  static Future<bool> isFileDownloaded(String localPath) async {
    return await File(localPath).exists();
  }

  static Future<List<Map<String, dynamic>>?> getUserDataByRoom(
      types.Room room, Map<String, dynamic> metaData) async {
    try {
      // Create a reference to the Firestore collection for the specified room
      final DocumentReference roomRef =
          FirebaseFirestore.instance.collection('rooms').doc(room.id);
      // Get the room document snapshot
      final DocumentSnapshot roomSnapshot = await roomRef.get();
      // Check if the room document exists
      if (roomSnapshot.exists) {
        // Extract the user IDs from the room document
        final Map<String, dynamic>? data =
            roomSnapshot.data() as Map<String, dynamic>?;
        final List<String> userIds = List<String>.from(data?['userIds'] ?? []);
        // Fetch user data for each user ID excluding the current user
        final List<Map<String, dynamic>> otherUserDataList = [];
        for (String userId in userIds) {
          if (userId != AuthService().firebaseAuth.currentUser!.uid) {
            // Create a reference to the Firestore collection for user data
            final DocumentReference userRef =
                FirebaseFirestore.instance.collection('users').doc(userId);
            // Get the user document snapshot
            final DocumentSnapshot userSnapshot = await userRef.get();
            // Check if the user document exists
            if (userSnapshot.exists) {
              // Extract the user data
              Map<String, dynamic> userData =
                  userSnapshot.data() as Map<String, dynamic>;
              // Add metaData to user data
              metaData = userData['metadata'];
              // Add the user data to the list
              otherUserDataList.add(userData);
            }
          }
        }

        // Return the list of other user data
        return otherUserDataList;
      } else {
        // Room document doesn't exist
        log('Room not found with ID: $room.id');
      }
    } catch (e) {
      // Error fetching user data
      log('Error fetching other user data from room: $e');
    }
    return null;
  }

  static bool isUserTyping(OwnRoom room, RxBool isTyping) {
    final currentUserId = AuthService().firebaseAuth.currentUser?.uid;

    // Ensure the current user is authenticated and metadata exists
    if (currentUserId != null &&
        room.metadata != null &&
        room.metadata!.isNotEmpty) {
      // Extract the first user ID from metadata
      final userId = room.metadata!.keys.first;

      // Check if the user ID is not the current user and if the typing status is true
      if (userId != currentUserId && room.metadata![userId] == true) {
        isTyping.value = true;
        log('User with ID $userId is typing');
        return true;
      }
    }

    // Reset typing status if conditions are not met
    isTyping.value = false;
    return false;
  }

  // <><><><><><><><><><><> Send Custom Files in Chat ===> Doc etc... <><><><><><><><><><><><><>
  static Future<void> sendCustomFiles(
      types.Room room, BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          // allowMultiple: true,
          // allowedExtensions: AppConst.fileExtensions,
          onFileLoading: (val) {
            log(val.toString());
          });

      if (result != null) {
        int totalSize =
            result.files.fold(0, (prev, element) => prev + element.size);
        int maxSizeAllowed = 500 * 1024 * 1024; // 500MB in bytes

        if (totalSize <= maxSizeAllowed) {
          // Show loading indicator while uploading files
          CustomLoadingIndicator.customLoading();

          for (final file in result.files) {

            final downloadUrl =
                await DBServiceForStoringOnline.saveMediaFileInStorage(
              imageFile: File(file.path!),
              userId: AuthService().firebaseAuth.currentUser!.uid,
              authorId: room.lastMessages![0].author.id,
            );
            if (downloadUrl != null) {
              final message = types.PartialFile(
                size: file.size,
                uri: downloadUrl,
                name: file.name,
              );

              AuthService().firebaseChatCore.sendMessage(message, room.id);
            } else {
              // Handle error if file upload fails
              log('Error uploading file: $file');
            }
          }

          // Close the loading indicator dialog
          Get.back();
        } else {
          // Show dialog if file size exceeds the limit
          Get.dialog(
            AlertDialog(
              title: CommonWidget.buildCustomText(text: 'File Size Exceeded'),
              content: CommonWidget.buildCustomText(
                  text:
                      'The selected file exceeds the maximum allowed size of 500MB.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      Logger().e('Error while sending files $e');
    }
  }
}
