import 'dart:developer';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:horaz/screens/ChatScreen/chat_export.dart';
import 'package:horaz/screens/HomeScreen/export.dart';
import 'package:horaz/utils/CameraUtils/CustomCameraController.dart';
import 'package:horaz/utils/VideoButton.dart';

class CustomCamera extends GetView<CustomCameraController> {
  const CustomCamera({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CustomCameraController());

    return Scaffold(
      backgroundColor: const Color(0xff1B1C20),
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(25),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xff1B1C20),
        ),
      ),
      body: _buildCameraView(),
    );
  }

  Widget _buildCameraView() {
    return Obx(
      () => controller.isCameraInitialized.value
          ? Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Center(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: controller.cameraControllerInstance.value!
                          .buildPreview(),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: flashModeToggleButton(),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 40,
                      right: 40,
                      child: middleCameraSection(),
                    ),
                  ],
                ),
              ),
            )
          : Container(),
    );
  }


  Widget middleCameraSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        !controller.isRecordingInProgress.value
            ? InkWell(
                onTap: () {
                  controller.switchCamera();
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black26,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.circle,
                        color: Colors.transparent,
                        size: 50,
                      ),
                    ),
                    Transform.rotate(
                      angle: 80,
                      child: const Icon(
                        FluentIcons.arrow_sync_12_regular,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                height: 50,
                width: 50,
                color: Colors.transparent,
              ),
        Obx(
          () => GestureDetector(
            onTap: () async {
              await controller.captureImageAndSave();
            },
            onLongPress: () async {
              await controller.startVideoRecording();
            },
            onLongPressEnd: (val) async {
              await controller.stopVideoRecording();
            },
            child: !controller.isRecordingInProgress.value
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 74,
                        width: 74,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white38,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                      const Icon(Icons.circle, color: Colors.white, size: 65),
                    ],
                  )
                : const AnimatedBorderButton(size: 100),
          ),
        ),
        controller.captureImage.value != null
            ? InkWell(
                onTap: () {
                  controller.getImage();
                },
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    image: controller.captureImage.value != null
                        ? DecorationImage(
                            image: FileImage(controller.captureImage.value!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
              )
            : Container(
                height: 50,
                width: 50,
                color: Colors.transparent,
              ),
      ],
    );
  }

  Widget flashModeToggleButton() {
    return IconButton(
      onPressed: () {
        controller.toggleFlashMode();
      },
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black26,
        ),
        child: Obx(
          () => Icon(
            controller.getFlashIcon(controller.currentFlashMode.value),
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}
