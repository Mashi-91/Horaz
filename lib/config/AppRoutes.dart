

import 'package:horaz/screens/PhoneScreen/AddPhoneCallScreen/AddPhoneCallBinding.dart';
import 'package:horaz/screens/PhoneScreen/AddPhoneCallScreen/AddPhoneCallScreen.dart';
import 'package:horaz/screens/PhoneScreen/PhoneListCommunityScreen/PhoneListCommunityBinding.dart';
import 'package:horaz/screens/PhoneScreen/PhoneListCommunityScreen/PhoneListCommunityScreen.dart';

import 'export.dart';

class AppRoutes {
  static const onBoardingScreen = '/OnBoardingScreen';
  static const authScreen = '/AuthScreen';
  static const logInScreen = '/LogInScreen';
  static const signUpScreen = '/SignUpScreen';
  static const homeNavigationScreen = '/HomeNavigationScreen';
  static const homeScreen = '/homeScreen';
  static const storyScreen = '/StoryScreen';
  static const phoneScreen = '/PhoneScreen';
  static const chatScreen = '/ChatScreen';
  static const chooseContactScreen = '/ChooseContactScreen';
  static const profileScreen = '/ProfileScreen';
  static const chatUserProfileScreen = '/ChatUserProfileScreen';
  static const profileQrScreen = '/ProfileQrScreen';
  static const addCommunityScreen = '/AddCommunityScreen';
  static const addSecondCommunityScreen = '/AddSecondCommunityScreen';
  static const communityProfileScreen = '/CommunityProfileScreen';
  static const editCommunityScreen = '/EditCommunityScreen';
  static const communityListScreen = '/CommunityListScreen';
  static const searchScreen = '/SearchScreen';
  static const addPhoneCallScreen = '/AddPhoneCallScreen';
  static const phoneListCommunityScreen = '/PhoneListCommunityScreen';
}

class AppPages {
  static List<GetPage> pages = [
    GetPage(
      name: AppRoutes.onBoardingScreen,
      page: () => const OnBoardingScreen(),
      binding: OnBoardingBinding(),
      curve: Curves.linear,
    ),
    GetPage(
      name: AppRoutes.logInScreen,
      page: () => const LogInScreen(),
      binding: LogInBinding(),
    ),
    GetPage(
      name: AppRoutes.signUpScreen,
      page: () => const SignUpScreen(),
      binding: SignUpBinding(),
      curve: Curves.linear,
    ),
    GetPage(
      name: AppRoutes.homeNavigationScreen,
      page: () => const HomeNavigationScreen(),
      binding: HomeBinding(),
      curve: Curves.linear,
    ),
    GetPage(
      name: AppRoutes.homeScreen,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      curve: Curves.linear,
    ),
    GetPage(
      name: AppRoutes.storyScreen,
      page: () => const StoryScreen(),
      binding: HomeBinding(),
      curve: Curves.linear,
    ),
    GetPage(
      name: AppRoutes.phoneScreen,
      page: () => const PhoneScreen(),
      binding: HomeBinding(),
      curve: Curves.linear,
    ),
    GetPage(
      name: AppRoutes.chatScreen,
      page: () => ChatScreen(),
      binding: ChatBinding(),
      curve: Curves.linear,
    ),
    GetPage(
      name: AppRoutes.chooseContactScreen,
      page: () => const ChooseContactScreen(),
      binding: ChooseContactBinding(),
      curve: Curves.linear,
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: AppRoutes.profileScreen,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
      curve: Curves.linear,
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: AppRoutes.chatUserProfileScreen,
      page: () => const ChatUserProfileScreen(),
      binding: ChatUserProfileBinding(),
      curve: Curves.linear,
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: AppRoutes.profileQrScreen,
      page: () => const ProfileQrScreen(),
      binding: ProfileQrBinding(),
      curve: Curves.linear,
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: AppRoutes.addCommunityScreen,
      page: () => const AddCommunityScreen(),
      binding: AddCommunityBinding(),
      curve: Curves.linear,
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: AppRoutes.addSecondCommunityScreen,
      page: () => const AddSecondCommunityScreen(),
      binding: AddCommunityBinding(),
      curve: Curves.linear,
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.communityProfileScreen,
      page: () => const CommunityProfileScreen(),
      binding: CommunityProfileBinding(),
      curve: Curves.linear,
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.editCommunityScreen,
      page: () => const EditCommunityScreen(),
      binding: EditCommunityBinding(),
      curve: Curves.linear,
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.communityListScreen,
      page: () => const CommunityListScreen(),
      binding: CommunityListBinding(),
      curve: Curves.linear,
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.searchScreen,
      page: () => const SearchScreen(),
      binding: SearchScreenBinding(),
      curve: Curves.linear,
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: AppRoutes.addPhoneCallScreen,
      page: () => const AddPhoneCallScreen(),
      binding: AddPhoneCallBinding(),
      curve: Curves.linear,
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: AppRoutes.phoneListCommunityScreen,
      page: () => const PhoneListCommunityScreen(),
      binding: PhoneListCommunityBinding(),
      curve: Curves.linear,
      transition: Transition.circularReveal,
    )
  ];
}
