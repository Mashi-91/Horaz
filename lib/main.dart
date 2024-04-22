import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/screens/ChatScreen/chat_export.dart';
import 'package:horaz/service/PermissionService.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:horaz/service/StreamCallService.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:sizer/sizer.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'firebase_options.dart';

int? isViewed;
int? isLogin;
Map? globalMetaData;

Future<void> main() async {
  await _initialize();
  isViewed = await AppUtils.getTokenInSharedPrefAsInt(key: "ONBOARDINGTOKEN");
  isLogin = await AppUtils.getTokenInSharedPrefAsInt(key: "LoginSuccessfully");
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// 1.1.2: set navigator key to ZegoUIKitPrebuiltCallInvitationService
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  // call the useSystemCallingUI
  ZegoUIKit().initLog().then((value) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );

    runApp(MyApp(navigatorKey: navigatorKey));
  });
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  MyApp({Key? key, required this.navigatorKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Horaz',
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
            scaffoldBackgroundColor: AppColors.primaryLightColor,
            appBarTheme:
                AppBarTheme(backgroundColor: AppColors.primaryLightColor),
            useMaterial3: true,
            fontFamily: 'Geometria',
          ),
          initialRoute: isViewed == 0 || isViewed == null
              ? AppRoutes.onBoardingScreen
              : isLogin == 0 || isLogin == null
                  ? AppRoutes.logInScreen
                  : AppRoutes.homeNavigationScreen,
          getPages: AppPages.pages,
        );
      },
    );
  }
}

Future<void> _initialize() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  FlutterNativeSplash.remove();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (AuthService.currentUser != null) {
    globalMetaData = await FirestoreService().getUserFromLocalDB();
    await StreamCallService().onUserLogin(AuthService.currentUser!.uid,
        AuthService.currentUser!.displayName.toString());
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  PermissionService.setOptimalDisplayMode();
  PermissionService.getNotificationPermission();
}
