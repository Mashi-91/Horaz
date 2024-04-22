import 'package:horaz/models/CallHistoryModel.dart';
import 'package:horaz/screens/ChatScreen/chat_export.dart';
import 'package:logger/logger.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class PhoneController extends GetxController {
  RxList<Map<dynamic, dynamic>> callHistoryModel = <Map<dynamic, dynamic>>[].obs;

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

  void setCallHistoryModel(RxList<Map> data) {
    callHistoryModel.value = data;
  }


  Stream<QuerySnapshot<Map<String, dynamic>>>? getAllContactsFromStore() {
    try {
      return DBServiceForStoringOnline.firestore
          .collection('contactHistory')
          .where('membersId', arrayContains: AuthService.currentUser!.uid)
          .snapshots();
    } catch (e) {
      Logger().e('While Getting All Contacts $e');
      return null;
    }
  }

  Future<void> deleteContact(String id) async {
    try {
      callHistoryModel.clear();
      await DBServiceForStoringOnline.firestore
          .collection('contactHistory').doc(id).delete();
    } catch (e) {
      Logger().e('While Deleting Contact $e');
    }
  }
}
