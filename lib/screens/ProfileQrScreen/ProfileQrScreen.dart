import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/screens/HomeScreen/export.dart';
import 'package:horaz/screens/ProfileQrScreen/PrtofileQrController.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfileQrScreen extends GetView<ProfileQrController> {
  const ProfileQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final metadata = Get.arguments;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios_rounded, size: 24),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              onTap: () {
                controller.shareContact();
              },
              child: const Icon(
                Icons.share,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22).copyWith(top: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonWidget.buildCustomText(
              text: 'Your QR Code',
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            CommonWidget.buildCustomText(
              text: 'Share this code to share your contact',
              textStyle: TextStyle(
                fontSize: 13,
                color: AppColors.blackColor.withOpacity(0.6),
                letterSpacing: 0,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 80),
            Container(
              height: 440,
              width: Get.width,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: Colors.transparent,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.only(top: 34),
                      height: 400,
                      width: Get.width,
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Column(
                        children: [
                          CommonWidget.buildCustomText(
                            text:
                                '${metadata['firstName']}',
                            textStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          CommonWidget.buildCustomText(
                            text: '+91 ${metadata['metadata']['phoneNumber']}',
                            textStyle: TextStyle(
                              fontSize: 10,
                              letterSpacing: 0,
                              color: AppColors.blackColor.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 60),
                          QrImageView(
                            data:
                                'Name: ${controller.currentUser!.displayName}, Phone Number: ${metadata['phoneNumber']}',
                            size: 180,
                            padding: EdgeInsets.zero,
                            version: QrVersions.auto,
                            eyeStyle: QrEyeStyle(
                                color: AppColors.primaryColor,
                                eyeShape: QrEyeShape.square),
                            dataModuleStyle: QrDataModuleStyle(
                                color: AppColors.primaryColor,
                                dataModuleShape: QrDataModuleShape.square),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 110,
                    // right: ,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        shape: BoxShape.circle,
                      ),
                      child: CommonWidget.buildCircleAvatar(
                        size: 30,
                        imageUrl: controller.currentUser!.photoURL.toString(),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
