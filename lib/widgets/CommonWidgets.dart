import 'dart:developer';

import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:horaz/utils/AppUtils.dart';
import 'package:horaz/widgets/CustomToggleButton.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CommonWidget {
  static Widget buildCustomText({
    required String text,
    TextStyle? textStyle,
    TextAlign? textAlign,
    EdgeInsets? margin,
    int? maxLine,
  }) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Text(
        text,
        maxLines: maxLine,
        textAlign: textAlign,
        style: textStyle,
      ),
    );
  }

  static Widget buildCustomDivider({
    double? height,
    double? width,
    required Color color,
  }) {
    return Container(
      height: 4,
      width: 14,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1),
        color: color,
      ),
    );
  }

  static Widget buildZegoCallButton({
    iconPath,
    required bool isVideo,
    required List<ZegoUIKitUser> invitee,
    required Function(String, String, List<String>) onPressed,
  }) {
    return ZegoSendCallInvitationButton(
      onPressed: (code, message, p2) => onPressed(code, message, p2),
      borderRadius: 0,
      clickableBackgroundColor: Colors.transparent,
      isVideoCall: isVideo,
      unclickableBackgroundColor: Colors.transparent,
      buttonSize: const Size(26, 26),
      iconSize: const Size(26, 26),
      margin: EdgeInsets.only(right: isVideo ? 0 : 30),
      icon: ButtonIcon(
          icon: AppUtils.svgToIcon(
        iconPath: iconPath,
      )),
      resourceID: "Horaz_Resource_Id",
      invitees: invitee,
    );
  }

  static Widget stackImage({
    required List<ImageProvider> images,
    double? width,
    double? height,
  }) {
    return AvatarStack(
      width: width ?? 110,
      height: height ?? 32,
      borderWidth: 1.2,
      infoWidgetBuilder: (i) {
        return CircleAvatar(
          backgroundColor: const Color(0xff1A1167),
          child: CommonWidget.buildCustomText(
            text: "+$i",
            textStyle: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: AppColors.whiteColor),
          ),
        );
      },
      settings: RestrictedPositions(
        maxCoverage: 0.2,
        minCoverage: 0.1,
        laying: StackLaying.first,
      ),
      avatars: images,
    );
  }

  static Widget buildCustomIcon({
    required IconData iconData,
    double? size,
    Color? color,
    EdgeInsetsGeometry? margin,
  }) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Icon(
        iconData,
        size: size,
        color: color,
      ),
    );
  }

  static Widget buildCircleButton({
    Color? bgColor,
    Color? iconColor,
    required VoidCallback onTap,
    IconData? iconData,
    bool isIcon = true,
    Widget? child,
    bool isShadow = false,
    EdgeInsets? padding,
    double? iconSize,
    bool isGradient = true,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            isShadow ? BoxShadow(
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(0,1),
              color: AppColors.greyColor.withOpacity(0.6),
            ) : const BoxShadow(),
          ],
          gradient: isGradient
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xff9552F5),
                    // Color(0xff9452F5),
                    // Color(0xff8C54F5),
                    AppColors.primaryColor,
                    AppColors.primaryColor,
                  ],
                )
              : null,
        ),
        child: isIcon
            ? CommonWidget.buildCustomIcon(
                iconData: iconData ?? Icons.arrow_forward_ios_rounded,
                color: iconColor ?? AppColors.whiteColor,
                size: iconSize ?? 16,
              )
            : child,
      ),
    );
  }

  static Widget buildGradientAddButton({
    double? height,
    double? width,
    double? iconSize,
    double? radius,
    EdgeInsets? margin,
    required Function onTap,
  }) {
    return InkWell(
      onTap: () => onTap(),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        margin: margin,
        height: height ?? 20,
        width: width ?? 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius ?? 12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xff9552F5),
              // Color(0xff9452F5),
              // Color(0xff8C54F5),
              AppColors.primaryColor,
              AppColors.primaryColor,
            ],
          ),
        ),
        child: Icon(
          Icons.add,
          color: AppColors.whiteColor,
          size: iconSize,
        ),
      ),
    );
  }

  static Widget buildCustomTextField({
    required String hintText,
    required TextEditingController controller,
    TextInputType? keyboardType,
    TextInputAction? keyboardAction,
    bool obsecure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obsecure,
      textInputAction: keyboardAction,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18).copyWith(left: 30),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(20),
        ),
        filled: true,
        fillColor: AppColors.primaryLightColor,
      ),
    );
  }

  static Widget buildLinearButtonWithIcon({
    required VoidCallback onTap,
    String? text,
    bool isTextEnable = true,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xff9552F5),
              // Color(0xff9452F5),
              // Color(0xff8C54F5),
              AppColors.primaryColor,
              AppColors.primaryColor,
            ],
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: AppColors.whiteColor, size: 22),
            const SizedBox(width: 4),
            if (isTextEnable)
              buildCustomText(
                text: text ?? '',
                textStyle: TextStyle(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Widget chatBubbleOption({
    required IconData iconData,
    required String title,
    required Function onTap,
    bool isSent = false,
  }) {
    return ListTile(
      onTap: () => onTap(),
      leading: Icon(iconData,
          color: isSent ? AppColors.whiteColor : AppColors.primaryColor),
      title: CommonWidget.buildCustomText(
        text: title,
        textStyle: TextStyle(
          color: isSent ? AppColors.whiteColor : AppColors.blackColor,
        ),
      ),
    );
  }

  static Widget buildCircleAvatar({
    String? imageUrl,
    double? size,
  }) {
    return CircleAvatar(
      radius: size ?? 23,
      backgroundImage: imageUrl != null
          ? CachedNetworkImageProvider(
              imageUrl,
            )
          : null,
      child: imageUrl == null
          ? AppUtils.svgToIcon(
              iconPath: 'empty-profile-icon.svg',
              height: 44,
            )
          : null,
    );
  }

  static Widget buildBackButton({double? size}) {
    return InkWell(
      onTap: () => Get.back(),
      child: Icon(Icons.arrow_back_ios_rounded, size: size ?? 30),
    );
  }

  static Widget buildContactTile({
    required types.User user,
    required Function onTap,
    Function? trailingIconTap,
    double? radius,
    bool isSelected = false,
    bool isCurrentUser = false,
    bool isTrailingIcon = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 28),
        border: isSelected
            ? Border.all(
                width: 2.4,
                color: AppColors.primaryColor,
              )
            : const Border(),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
        tileColor: AppColors.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 28),
        ),
        onTap: () => onTap(),
        leading: Stack(
          children: [
            CommonWidget.buildCircleAvatar(
              imageUrl: user.imageUrl.toString(),
            ),
            if (isSelected)
              CircleAvatar(
                radius: 23,
                backgroundColor: AppColors.blackColor.withOpacity(0.2),
                child: Icon(
                  Icons.done_rounded,
                  color: AppColors.whiteColor,
                  weight: 4,
                ),
              ),
          ],
        ),
        title: CommonWidget.buildCustomText(
          text: isCurrentUser ? 'You' : user.firstName.toString(),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: CommonWidget.buildCustomText(
          text: user.metadata?['email'] ?? '',
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        trailing: isTrailingIcon
            ? InkWell(
                onTap: isTrailingIcon ? () => trailingIconTap!() : () {},
                child: AppUtils.svgToIcon(
                    iconPath: 'phone-active-icon.svg',
                    height: 20,
                    margin: const EdgeInsets.only(right: 4)),
              )
            : null,
      ),
    );
  }

  static Widget buildCustomListProfileTile({
    required Color color,
    required IconData iconData,
    required String title,
    Function? onTap,
    bool isTopPadding = false,
    bool isLastIcon = true,
    required Function onNotificationTap,
    required bool isToggled,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26)
          .copyWith(bottom: 14, top: isTopPadding ? 20 : 0),
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: isLastIcon
            ? () {}
            : onTap != null
                ? () => onTap()
                : null,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(iconData, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            CommonWidget.buildCustomText(
              text: title,
              textStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            if (isLastIcon)
              const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            if (!isLastIcon)
              CustomToggleButton(
                isToggled: isToggled,
                onTap: () => onNotificationTap(),
                elevation: 0,
                height: 40,
                iconSize: 18,
                width: 90,
                iconPositionLeftIsOff: 2,
                iconPositionLeftIsOn: 52,
              ),
          ],
        ),
      ),
    );
  }
}
