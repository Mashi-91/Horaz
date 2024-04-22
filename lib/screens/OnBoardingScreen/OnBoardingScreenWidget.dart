import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/widgets/CommonWidgets.dart';
import 'package:sizer/sizer.dart';

class OnBoardingScreenWidget {
  static Widget pages({
    required String image,
    required String firstText,
    double? imageHeight,
    EdgeInsetsGeometry? textMargin,
    EdgeInsetsGeometry? imageMargin,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Column(
        children: [
          Padding(
            padding: imageMargin ?? EdgeInsets.zero,
            child: SvgPicture.asset(
              'assets/images/$image',
              height: imageHeight,
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: textMargin ?? EdgeInsets.zero,
            child: Column(
              children: [
                CommonWidget.buildCustomText(
                  text: firstText,
                  textStyle: TextStyle(
                    color: AppColors.darkPurple,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 1.h),
                CommonWidget.buildCustomText(
                  text:
                      'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium dolorernque.',
                  textStyle: TextStyle(
                    color: AppColors.greyColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget skipButton({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          CommonWidget.buildCustomText(
            text: 'Skip',
            textStyle: TextStyle(
              fontSize: 12,
              color: AppColors.greyColor,
            ),
          ),
          SizedBox(width: 1.w),
          CommonWidget.buildCustomIcon(
              iconData: Icons.arrow_forward_ios_rounded,
              color: AppColors.greyColor,
              size: 10,
              margin: EdgeInsets.only(right: 4.w)),
        ],
      ),
    );
  }
}
