import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:horaz/config/ApiKeys.dart';
import 'package:horaz/screens/ChatScreen/chat_export.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class StreamCallService {
  Future<void> onUserLogin(String userID, String userName) async {
    try {
      await ZegoUIKitPrebuiltCallInvitationService().init(
        appID: ApiKeys.AppId,
        appSign: ApiKeys.AppSign,
        userID: userID,
        userName: userName,
        plugins: [ZegoUIKitSignalingPlugin()],
      );
      log('Zego initialized successfully.');
    } catch (e) {
      log('Error while initializing Zego: $e');
    }
  }

  // Future<void> createEngine() async {
  //   await ZegoExpressEngine.createEngineWithProfile(ZegoEngineProfile(
  //     ApiKeys.AppId,
  //     ZegoScenario.Default,
  //     appSign: ApiKeys.AppSign,
  //   ));
  // }

  static String generateJWTToken(String userId) {
    // Define your JWT secret key
    String secret = ApiKeys.AppSign;

    // Create a map representing the payload
    Map<String, dynamic> payload = {
      'user_id': userId,
    };

    // Encode the payload
    String encodedPayload = base64Url.encode(utf8.encode(json.encode(payload)));

    // Create a map representing the header
    Map<String, dynamic> header = {
      'alg': 'HS256',
      'typ': 'JWT',
    };

    // Encode the header
    String encodedHeader = base64Url.encode(utf8.encode(json.encode(header)));

    // Concatenate the encoded header, payload, and signature with '.'
    String toSign = '$encodedHeader.$encodedPayload';

    // Create a HMAC-SHA256 hash of the toSign string using the secret key
    List<int> signatureBytes =
        Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(toSign)).bytes;

    // Encode the signature
    String encodedSignature = base64Url.encode(signatureBytes);

    // Concatenate the encoded header, payload, and signature to form the JWT token
    String jwtToken = '$encodedHeader.$encodedPayload.$encodedSignature';

    return jwtToken;
  }
}
