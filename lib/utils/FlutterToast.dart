import 'package:fluttertoast/fluttertoast.dart';
import 'package:horaz/config/AppColors.dart';

class FlutterToastMsg {
  static flutterToastMSG({required String msg}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: AppColors.primaryColor,
      textColor: AppColors.whiteColor,
      fontSize: 16.0,
    );
  }
}
