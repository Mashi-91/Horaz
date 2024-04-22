import 'dart:ui';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:horaz/config/ApiKeys.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/screens/ChatScreen/chat_export.dart';
import 'package:horaz/utils/ZegoTokenUtils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class CallPage extends StatefulWidget {
  const CallPage({
    super.key,
    required this.localUserID,
    required this.localUserName,
    required this.roomID,
  });

  final String localUserID;
  final String localUserName;
  final String roomID;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  Widget? localView;
  int? localViewID;
  Widget? remoteView;
  int? remoteViewID;
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    startListenEvent();
    loginRoom();
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    stopListenEvent();
    logoutRoom();
    super.dispose();
  }

  Future<void> _playRingingSound() async {
    try {
      // Play the audio file in a loop
      await audioPlayer.play(AssetSource('ringtone/outgoing-ringtone.mp3'));
      audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print('Error playing ringing sound: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   backgroundColor: Colors.transparent,
      // ),
      body: Stack(
        children: [
          localView ?? const SizedBox.shrink(),
          Positioned(
            top: MediaQuery.of(context).size.height / 20,
            right: MediaQuery.of(context).size.width / 20,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: AspectRatio(
                aspectRatio: 9.0 / 16.0,
                child: remoteView ?? Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height / 8,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              height: MediaQuery.of(context).size.height / 3,
              child: Column(
                children: [
                  CommonWidget.buildCustomText(
                    text: widget.localUserName,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.whiteColor,
                      fontSize: 30,
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff2A365E).withOpacity(0.3),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width / 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      callButtons(
                        onTap: () {},
                        iconData: FluentIcons.camera_switch_24_filled,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width / 34),
                      callButtons(
                        onTap: () {},
                        iconData: FluentIcons.mic_16_filled,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width / 34),
                      callButtons(
                        onTap: () {
                          audioPlayer.dispose();
                          stopListenEvent();
                          logoutRoom();
                          Navigator.of(context).pop();
                        },
                        iconData: FluentIcons.call_end_20_filled,
                        bgColor: AppColors.redColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget callButtons({
    required Function onTap,
    required IconData iconData,
    Color? bgColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor ?? AppColors.greyColor.withOpacity(0.4),
        ),
        child: Icon(
          iconData,
          color: iconColor ?? AppColors.whiteColor,
          size: 18,
        ),
      ),
    );
  }

  Future<ZegoRoomLoginResult> loginRoom() async {
    // The value of `userID` is generated locally and must be globally unique.
    final user = ZegoUser(widget.localUserID, widget.localUserName);

    // The value of `roomID` is generated locally and must be globally unique.
    final roomID = widget.roomID;

    // onRoomUserUpdate callback can be received when "isUserStatusNotify" parameter value is "true".
    ZegoRoomConfig roomConfig = ZegoRoomConfig.defaultConfig()
      ..isUserStatusNotify = true;

    if (kIsWeb) {
      // ! ** Warning: ZegoTokenUtils is only for use during testing. When your application goes live,
      // ! ** tokens must be generated by the server side. Please do not generate tokens on the client side!
      roomConfig.token = ZegoTokenUtils.generateToken(
          ApiKeys.AppId, ApiKeys.AppSecret, widget.localUserID);
    }
    // log in to a room
    // Users must log in to the same room to call each other.
    return ZegoExpressEngine.instance
        .loginRoom(roomID, user, config: roomConfig)
        .then((ZegoRoomLoginResult loginRoomResult) async {
      debugPrint(
          'loginRoom: errorCode:${loginRoomResult.errorCode}, extendedData:${loginRoomResult.extendedData}');
      if (loginRoomResult.errorCode == 0) {
        _playRingingSound();
        startPreview();
        startPublish();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('loginRoom failed: ${loginRoomResult.errorCode}')));
      }
      return loginRoomResult;
    });
  }

  Future<ZegoRoomLogoutResult> logoutRoom() async {
    await audioPlayer.stop();
    stopPreview();
    stopPublish();
    return ZegoExpressEngine.instance.logoutRoom(widget.roomID);
  }

  void startListenEvent() {
    // Callback for updates on the status of other users in the room.
    // Users can only receive callbacks when the isUserStatusNotify property of ZegoRoomConfig is set to `true` when logging in to the room (loginRoom).
    ZegoExpressEngine.onRoomUserUpdate =
        (roomID, updateType, List<ZegoUser> userList) {
      debugPrint(
          'onRoomUserUpdate: roomID: $roomID, updateType: ${updateType.name}, userList: ${userList.map((e) => e.userID)}');
    };
    // Callback for updates on the status of the streams in the room.
    ZegoExpressEngine.onRoomStreamUpdate =
        (roomID, updateType, List<ZegoStream> streamList, extendedData) async {
      debugPrint(
          'onRoomStreamUpdate: roomID: $roomID, updateType: $updateType, streamList: ${streamList.map((e) => e.streamID)}, extendedData: $extendedData');
      if (updateType == ZegoUpdateType.Add) {
        for (final stream in streamList) {
          await audioPlayer.stop();
          startPlayStream(stream.streamID);
        }
      } else {
        for (final stream in streamList) {
          await audioPlayer.stop();
          stopPlayStream(stream.streamID);
        }
      }
    };
    // Callback for updates on the current user's room connection status.
    ZegoExpressEngine.onRoomStateUpdate =
        (roomID, state, errorCode, extendedData) {
      debugPrint(
          'onRoomStateUpdate: roomID: $roomID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
    };

    // Callback for updates on the current user's stream publishing changes.
    ZegoExpressEngine.onPublisherStateUpdate =
        (streamID, state, errorCode, extendedData) {
      debugPrint(
          'onPublisherStateUpdate: streamID: $streamID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
    };
  }

  void stopListenEvent() {
    ZegoExpressEngine.onRoomUserUpdate = null;
    ZegoExpressEngine.onRoomStreamUpdate = null;
    ZegoExpressEngine.onRoomStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;
  }

  Future<void> startPreview() async {
    await ZegoExpressEngine.instance.createCanvasView((viewID) {
      localViewID = viewID;
      ZegoCanvas previewCanvas =
          ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
      ZegoExpressEngine.instance.startPreview(canvas: previewCanvas);
    }).then((canvasViewWidget) {
      setState(() => localView = canvasViewWidget);
    });
  }

  Future<void> stopPreview() async {
    ZegoExpressEngine.instance.stopPreview();
    if (localViewID != null) {
      await ZegoExpressEngine.instance.destroyCanvasView(localViewID!);
      if (mounted) {
        setState(() {
          localViewID = null;
          localView = null;
        });
      }
    }
  }

  Future<void> startPublish() async {
    // After calling the `loginRoom` method, call this method to publish streams.
    // The StreamID must be unique in the room.
    String streamID = '${widget.roomID}_${widget.localUserID}_call';
    return ZegoExpressEngine.instance.startPublishingStream(streamID);
  }

  Future<void> stopPublish() async {
    return ZegoExpressEngine.instance.stopPublishingStream();
  }

  Future<void> startPlayStream(String streamID) async {
    // Start to play streams. Set the view for rendering the remote streams.
    await ZegoExpressEngine.instance.createCanvasView((viewID) {
      remoteViewID = viewID;
      ZegoCanvas canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
    }).then((canvasViewWidget) {
      setState(() => remoteView = canvasViewWidget);
    });
  }

  Future<void> stopPlayStream(String streamID) async {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);
    if (remoteViewID != null) {
      ZegoExpressEngine.instance.destroyCanvasView(remoteViewID!);
      if (mounted) {
        setState(() {
          remoteViewID = null;
          remoteView = null;
        });
      }
    }
  }
}
