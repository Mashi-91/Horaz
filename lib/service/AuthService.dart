import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart'
    as firebaseCoreType;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:horaz/service/DBService.dart';
import 'package:horaz/service/EncryptionService.dart';
import 'package:horaz/service/StreamCallService.dart';
import 'package:logger/logger.dart';

class AuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final User? currentUser = FirebaseAuth.instance.currentUser;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final _firebaseChatCore = firebaseCoreType.FirebaseChatCore.instance;

  // static final fmessageInstance = FirebaseMessaging.instance;

  FirebaseAuth get firebaseAuth => _firebaseAuth;

  firebaseCoreType.FirebaseChatCore get firebaseChatCore => _firebaseChatCore;

  static Future<UserCredential?> createAccountWithFirebase({
    required String email,
    required String password,
    required dynamic pickImage,
    required String name,
    required String phoneNumber,
    Function(UserCredential)? onAccountCreated,
  }) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final profileUrl =
            await DBServiceForStoringOnline.saveProfilePicInStorage(
                pickImage!, userCredential.user!.uid);
        var token = await FirebaseMessaging.instance.getToken();
        await _firebaseChatCore.createUserInFirestore(
          types.User(
            id: userCredential.user!.uid,
            firstName: name,
            imageUrl: profileUrl,
            metadata: {
              'email': userCredential.user!.email,
              'phoneNumber': phoneNumber,
              'notification_token': token,
            },
          ),
        );
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.updatePhotoURL(profileUrl);
        return userCredential;
      } else {
        throw Exception('User is null after account creation.');
      }
    } on FirebaseAuthException catch (e) {
      Logger().e('FirebaseAuthException: $e');
      rethrow; // Rethrow the FirebaseAuthException
    } catch (e) {
      Logger().e('Unexpected error during account creation: $e');
      throw Exception('Unexpected error during account creation.');
    }
  }

  static Future<User?> loginWithFirebase({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        return userCredential.user; // Login successful
      }
    } on FirebaseAuthException catch (e) {
      Logger().e('FirebaseAuthException: $e');
      rethrow; // Rethrow the FirebaseAuthException
    } catch (e) {
      Logger().e('Unexpected error during login: $e');
      throw Exception('Unexpected error during login.');
    }
    return null; // Login failed (unexpected scenario)
  }

  static Future<User?> loginWithGoogle() async {
    try {
      // Trigger the Google Sign In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the GoogleSignInAuthentication object
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential using the GoogleSignInAuthentication object
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google Auth credentials
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      Logger().e('Error signing in with Google: $e');
      rethrow;
    }
  }

  static Future<void> sendMessageToFireStore(
      dynamic partialMessage, String roomId) async {
    if (AuthService().firebaseAuth.currentUser == null) return;

    types.Message? message;

    if (partialMessage is types.PartialCustom) {
      message = types.CustomMessage.fromPartial(
        author: types.User(id: AuthService().firebaseAuth.currentUser!.uid),
        id: '',
        partialCustom: partialMessage,
      );
    } else if (partialMessage is types.PartialFile) {
      message = types.FileMessage.fromPartial(
        author: types.User(id: AuthService().firebaseAuth.currentUser!.uid),
        id: '',
        partialFile: partialMessage,
      );
    } else if (partialMessage is types.PartialImage) {
      message = types.ImageMessage.fromPartial(
        author: types.User(id: AuthService().firebaseAuth.currentUser!.uid),
        id: '',
        partialImage: partialMessage,
      );
    } else if (partialMessage is types.PartialText) {
      final encrypted = EncryptionService.encryptMessage(partialMessage.text);
      final encryptedPartialMessage = types.PartialText(text: encrypted);
      message = types.TextMessage.fromPartial(
        author: types.User(id: AuthService().firebaseAuth.currentUser!.uid),
        id: '',
        partialText:
            encryptedPartialMessage, // Use the encrypted partial message
      );
    } else if (partialMessage is types.PartialVideo) {
      message = types.VideoMessage.fromPartial(
        author: types.User(id: AuthService().firebaseAuth.currentUser!.uid),
        id: '',
        partialVideo: partialMessage,
      );
    }

    if (message != null) {
      final messageMap = message.toJson();
      messageMap.removeWhere((key, value) => key == 'author' || key == 'id');
      messageMap['authorId'] = AuthService().firebaseAuth.currentUser!.uid;
      messageMap['createdAt'] = FieldValue.serverTimestamp();
      messageMap['updatedAt'] = FieldValue.serverTimestamp();

      await DBServiceForStoringOnline.firestore
          .collection(
              '${AuthService().firebaseChatCore.config.roomsCollectionName}/$roomId/messages')
          .add(messageMap);

      await DBServiceForStoringOnline.firestore
          .collection(AuthService().firebaseChatCore.config.roomsCollectionName)
          .doc(roomId)
          .update({'updatedAt': FieldValue.serverTimestamp()});
    }
  }
}
