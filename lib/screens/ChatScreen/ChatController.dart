import 'dart:developer';
import 'dart:io';

import 'chat_export.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatController extends FullLifeCycleController
    with WidgetsBindingObserver {
  final firebaseChatInstance = AuthService().firebaseChatCore;
  List<types.Message> initialMessages = [];
  String lastMessageID = '';
  RxBool isTyping = false.obs;
  RxBool isOnline = false.obs;
  final isFileLoading = false.obs;
  Map<String, dynamic> metaData = {};
  RxMap updatedRoom = {}.obs;
  StreamSubscription<DocumentSnapshot>? userSubscription;
  bool isLoad = false;

  types.User convertFirebaseUserToChatUser(User firebaseUser) {
    return types.User(
      id: firebaseUser.uid,
      firstName: firebaseUser.displayName ?? '',
      imageUrl: firebaseUser.photoURL ?? '',
      lastName: '',
    );
  }

  types.User get currentUser =>
      convertFirebaseUserToChatUser(FirebaseAuth.instance.currentUser!);

  @override
  void dispose() {
    userSubscription?.cancel();
    super.dispose();
  }

  @override
  Future<void> onInit() async {
    await getUserDataByRoom();
    WidgetsBinding.instance.addObserver(this);
    checkOtherUserOnlineInRoom();
    super.onInit();
  }

  Future getUpdatedRoom(types.Room room, users) async {
    final result = await Get.toNamed(
      users
          ? AppRoutes.communityProfileScreen
          : AppRoutes.chatUserProfileScreen,
      arguments: [room, metaData],
    );
    updatedRoom.value = result;
  }

  void storeMsgData(val) {
    initialMessages = val;
    isLoad = true;
    update();
  }

  Future<List<Map<String, dynamic>>?> getUserDataByRoom() async {
    try {
      final types.Room room = Get.arguments;
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
              metaData = userData;
              update();
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

  Future<void> getRoomByUserId(String id) async {
    final roomSnapshot = await DBServiceForStoringOnline.firestore
        .collection('rooms')
        .doc(id)
        .get();
    final roomData = roomSnapshot.data() as Map<String, dynamic>;
    final convertData = OwnRoom.fromJson(roomData);
    AppUtils.isUserTyping(convertData, isTyping);
  }

  // <><><><><><><><><><><><><><> Send Message Text <><><><><><><><><><><><><><>
  Future<void> sendTextMessage(types.User user,
      String text /*, types.Message repliedMessage*/, types.Room room) async {
    // Create a partial text message
    final types.PartialText partialTextMessage = types.PartialText(
      text: text,
      // repliedMessage: repliedMessage,
    );

    // Send the message to the selected user
    _sendMessage(partialTextMessage, room).then((value) async {
      try {
        final authorId = room.users
            .firstWhere((val) => val.id != AuthService.currentUser!.uid)
            .id;
        final token =
        await AppUtils.getNotificationTokenFromUserCollection(authorId);
        final messageType = partialTextMessage.runtimeType == types.TextMessage
            ? partialTextMessage.text
            : "image";

        await APIsServices.sendPushNotification(
          user: AuthService.currentUser!,
          nToken: token ?? '', // Make sure token is not null
          msg: partialTextMessage.text,
        );
      } catch (e) {
        log("$e");
      }
    });
  }

  // <><><><><><><><><><><><><><><> Open Messages in ChatScreen => Images.. <><><><><><><><><><><><><><><>
  Future<void> openMessagesByTappingThem(types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('https')) {
        final documentsDir = (await getExternalStorageDirectory())!.path;
        localPath = '$documentsDir/${message.name}';

        if (!await AppUtils.isFileDownloaded(localPath)) {
          CustomLoadingIndicator.customLoading();

          try {
            final response = await http.get(Uri.parse(message.uri));
            if (response.statusCode == 200) {
              final file = File(localPath);
              await file.writeAsBytes(response.bodyBytes);

              // Open the file using OpenFilex
              OpenFilex.open(localPath);
            } else {
              // Handle HTTP error
              Get.snackbar('Error', 'Failed to download file');
            }
          } catch (e) {
            // Handle download error
            Get.snackbar('Error', 'Failed to download file');
          } finally {
            Get.back();
          }
        } else {
          // Open the already downloaded file using OpenFilex
          OpenFilex.open(localPath);
        }
      } else {
        // Handle local file opening
        OpenFilex.open(localPath);
      }
    }
  }

  // <><><><><><><><><><><> Handle Media Is Video Or Image <><><><><><><><><><><><><<>
  // Future<void> handleMediaIsVideoOrImage(BuildContext context, room) async {
  //   final result = await GalleryPicker.pickMedia(
  //     context: context,
  //     pageTransitionType: PageTransitionType.fade,
  //   );
  //
  //   if (result != null && result.isNotEmpty) {
  //     for (final media in result) {
  //       CustomLoadingIndicator.customLoading();
  //       if (media.type == MediaType.image) {
  //         // Handle image
  //         await _handleGalleryForImage(media, room);
  //         Get.back();
  //       } else if (media.type == MediaType.video) {
  //         // Handle video
  //         await _handleGalleryForVideo(media, room);
  //         Get.back();
  //       }
  //     }
  //   }
  // }

  // Future<void> _handleGalleryForImage(MediaFile media, room) async {
  //   final imageData = await media.getFile();
  //   final imageUrl = await DBServiceForStoringOnline.saveMediaInStorage(
  //     imageFile: File(imageData.path),
  //     userId: AuthService().firebaseAuth.currentUser!.uid,
  //     authorId: room.lastMessages![0].author.id,
  //   );
  //   final bytes = await imageData.readAsBytes();
  //   final image = await decodeImageFromList(bytes);
  //
  //   final message = types.PartialImage(
  //     height: image.height.toDouble(),
  //     name: imageData.uri.toString(),
  //     size: bytes.length,
  //     uri: imageUrl.toString(),
  //     width: image.width.toDouble(),
  //   );
  //
  //   await _sendMessage(message, room);
  // }

  // Future<void> _handleGalleryForVideo(MediaFile media, room) async {
  //   final videoData = await media.getFile();
  //   final videoUrl = await DBServiceForStoringOnline.saveMediaFileInStorage(
  //     imageFile: File(videoData.path),
  //     userId: AuthService().firebaseAuth.currentUser!.uid,
  //     authorId: room.lastMessages![0].author.id,
  //   );
  //   final size = videoData.lengthSync();
  //
  //   final message = types.PartialVideo(
  //     name: videoData.uri.toString(),
  //     size: size,
  //     uri: videoUrl.toString(),
  //   );
  //
  //   await _sendMessage(message, room);
  // }

  void openCamera(types.Room room) async {
    final result = await ImagePicker().pickImage(
      imageQuality: 50,
      maxWidth: 1080,
      source: ImageSource.camera,
    );

    if (result != null) {
      final imageUrl = await DBServiceForStoringOnline.saveMediaInStorage(
        imageFile: File(result.path),
        userId: AuthService().firebaseAuth.currentUser!.uid,
        authorId: room.lastMessages![0].author.id,
      );
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.PartialImage(
        height: image.height.toDouble(),
        name: result.name,
        size: bytes.length,
        uri: imageUrl.toString(),
        width: image.width.toDouble(),
      );

      await _sendMessage(message, room);
    }
  }

  Future<void> _sendMessage(message, types.Room room) async {
    // Send the message to the selected user
    AuthService.sendMessageToFireStore(message, room.id);

    // Fetch the last message from FireStore to get its ID
    await firebaseChatInstance
        .messages(room)
        .first
        .then((List<types.Message> messages) async {
      if (messages.isNotEmpty) {
        final lastMessageId = messages.first.id;
        lastMessageID = messages.first.id;

        // Call this function when a message is sent
        await FirestoreService().changeLastMessage(room.id, lastMessageId);
        await FirestoreService().changeMessageStatus(room.id, lastMessageId);
      }
      AppUtils.updateTypingStatus(
          room.id, FirebaseAuth.instance.currentUser?.uid, false);
    });
  }

// Function to listen for changes in user's online status
  Future<void> checkOtherUserOnlineInRoom() async {
    try {
      final types.Room room = Get.arguments;
      final roomRef =
      FirebaseFirestore.instance.collection('rooms').doc(room.id);

      // Listen for changes in the room document
      final roomStream = roomRef.snapshots();
      roomStream.listen((roomSnapshot) async {
        if (roomSnapshot.exists) {
          final List<String> userIds =
          List<String>.from(roomSnapshot.data()?['userIds'] ?? []);

          // Listen for changes in each user's online status
          for (String userId in userIds) {
            if (userId != currentUser.id) {
              final userRef =
              FirebaseFirestore.instance.collection('users').doc(userId);

              // Listen for changes in the user document
              final userStream = userRef.snapshots();
              userStream.listen((userSnapshot) {
                final presence = userSnapshot.data()?['isOnline'];
                if (presence == 'online') {
                  // At least one user is online, set isOnline to true
                  isOnline.value = true;
                  return; // Exit the loop once online status is detected
                }
              });
            }
          }

          // If no user is online, set isOnline to false
          isOnline.value = false;
        } else {
          // Room doesn't exist, set isOnline to false
          isOnline.value = false;
        }
      });
    } catch (e) {
      // Handle error
      log('Error checking other user presence: $e');
      isOnline.value = false;
    }
  }



}
