import 'dart:developer';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'chat_export.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final room = Get.arguments as types.Room;
    return Scaffold(
      appBar: ChatScreenWidget.buildChatAppBar(room),
      body: StreamBuilder<List<types.Message>>(
        stream: AuthService().firebaseChatCore.messages(room,limit: 10),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomLoadingIndicator.customLoadingWithoutDialog();
          }
          if (snapshot.hasData) {
            controller.initialMessages.clear();
            controller.storeMsgData(snapshot.data);
            return Chat(
              messages: controller.initialMessages,
              scrollToUnreadOptions: ScrollToUnreadOptions(
                scrollOnOpen: true,
                lastReadMessageId: controller.lastMessageID,
              ),
              videoMessageBuilder: (msgVal, {required int messageWidth}) {
                return SizedBox(
                  height: 400,
                  width: messageWidth.toDouble(),
                  child: VideoViewPage(path: msgVal.uri),
                );
              },
              onMessageTap: (context, types.Message message) async {
                controller.openMessagesByTappingThem(message);
              },
              fileMessageBuilder: (msgValue, {required int messageWidth}) {
                return ChatScreenWidget.buildFileMessageTile(
                    msgValue: msgValue, msgWidth: messageWidth);
              },
              onPreviewDataFetched:
                  (textMessage, types.PreviewData previewData) {
                // Handle preview data fetched
              },
              onMessageLongPress: (onMessageLongPressContext, dynamic msg) {
                final RenderBox renderBox =
                    onMessageLongPressContext.findRenderObject() as RenderBox;
                final position = renderBox.localToGlobal(Offset.zero);
                final isSentMessage =
                    msg.author.id == controller.currentUser.id;
                showDialog(
                  context: context,
                  builder: (_) {
                    return CustomChatBubble(
                      position: position,
                      isSent: isSentMessage,
                      msg: msg,
                      room: room,
                    );
                  },
                );
              },
              onSendPressed: (types.PartialText message) {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  controller.sendTextMessage(
                    types.User(
                      id: room.id,
                      firstName: room.name,
                      imageUrl: room.imageUrl,
                      createdAt: room.createdAt,
                    ),
                    message.text,
                    room,
                  );
                }
              },
              textMessageBuilder: (msg,
                  {required int messageWidth, required bool showName}) {
                return ChatScreenWidget.buildCustomTextMessageBubble(
                  msg: msg,
                  msgWidth: messageWidth,
                  showName: showName,
                );
              },
              onAttachmentPressed: () {},
              showUserAvatars: room.users.length == 3 ? true : false,
              theme: ChatScreenWidget.buildChatTheme(room, context),
              inputOptions: InputOptions(
                onTextChanged: (val) {
                  if (val.isEmpty) {}
                  AppUtils.updateTypingStatus(room.id,
                      FirebaseAuth.instance.currentUser?.uid, val.isNotEmpty);
                  controller.getRoomByUserId(room.id);
                },
              ),
              user: controller.currentUser,
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: CommonWidget.buildCustomText(
                  text:
                      'Say Hi to your ${room.users.length == 3 ? 'community' : 'friend'} 👋'),
            );
          } else {
            // Handle loading state
            return CustomLoadingIndicator.customLoadingWithoutDialog();
          }
        },
      ),
    );
  }
}
