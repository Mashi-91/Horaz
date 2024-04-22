import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:horaz/config/AppRoutes.dart';
import 'package:horaz/models/StoryModel.dart';
import 'package:horaz/utils/CameraUtils/CameraImagePreview.dart';
import 'package:horaz/utils/CameraUtils/CameraVideoPreview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CustomCameraController extends GetxController {
  Rx<CameraController?> cameraControllerInstance = Rx<CameraController?>(null);

  RxInt currentPage = 0.obs;
  Rx<FlashMode?> currentFlashMode = Rx<FlashMode?>(null);
  List<CameraDescription> cameras = [];

  RxBool isCameraInitialized = false.obs;
  RxBool isRearCameraSelected = true.obs;
  RxBool isRecordingInProgress = false.obs;

  Rx<File?> captureImage = Rx<File?>(null);
  Rx<File?> captureVideo = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  @override
  void onClose() {
    cameraControllerInstance.value?.dispose();
    super.onClose();
  }

  Future getImage() async {
    var image = ImagePicker();
    await image.pickImage(source: ImageSource.gallery);
  }



  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      onNewCameraSelected(cameras[0]);
    } catch (e) {
      log('Error initializing camera: $e');
    }
  }

  void _setFlashMode(FlashMode mode) async {
    if (cameraControllerInstance.value == null ||
        !cameraControllerInstance.value!.value.isInitialized) {
      return;
    }
    try {
      await cameraControllerInstance.value!.setFlashMode(mode);
      currentFlashMode.value = mode; // Update the current flash mode
      update();
    } catch (e) {
      log('Error setting flash mode: $e');
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = cameraControllerInstance.value;
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await previousCameraController?.dispose();
    cameraControllerInstance.value = cameraController;
    cameraController.addListener(() {
      update(); // Trigger UI update
    });
    try {
      await cameraController.initialize();
      currentFlashMode.value =
          cameraController.value.flashMode; // Set initial flash mode
    } on CameraException catch (e) {
      log('Error initializing camera: $e');
    }
    isCameraInitialized.value =
        cameraControllerInstance.value!.value.isInitialized;
  }

  // TODO <><><><><><><><><><> For Capturing Picture <><><><><><><><>
  Future<void> takePicture() async {
    if (cameraControllerInstance.value!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return;
    }
    try {
      XFile file = await cameraControllerInstance.value!.takePicture();
      await cameraControllerInstance.value!.setFlashMode(FlashMode.off);
      captureImage.value = File(file.path);
    } on CameraException catch (e) {
      log('Error occurred while taking picture: $e');
    }
  }

  // TODO <><><><><><><><><> For Starting Recording <><><><><><><><>
  Future<void> startVideoRecording() async {
    if (cameraControllerInstance.value!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }
    try {
      await cameraControllerInstance.value!.startVideoRecording();
      isRecordingInProgress.value = true;
      update();
    } on CameraException catch (e) {
      log('Error starting to record video: $e');
    }
  }

  // TODO <><><><><><><><><> For Stopping Recording <><><><><><><><>
  Future<XFile?> stopVideoRecording() async {
    if (!cameraControllerInstance.value!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }
    try {
      XFile file = await cameraControllerInstance.value!.stopVideoRecording();
      isRecordingInProgress.value = false;
      Get.to(CameraVideoPreview(file: File(file.path)));
      return file;
    } on CameraException catch (e) {
      log('Error stopping video recording: $e');
      return null;
    }
  }

  // TODO <><><><><><><><><> For Pause Recording <><><><><><><><>
  Future<void> pauseVideoRecording() async {
    if (!cameraControllerInstance.value!.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }
    try {
      await cameraControllerInstance.value!.pauseVideoRecording();
    } on CameraException catch (e) {
      log('Error pausing video recording: $e');
    }
  }

  // TODO <><><><><><><><><> For Resume Recording <><><><><><><><>
  Future<void> resumeVideoRecording() async {
    if (!cameraControllerInstance.value!.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }
    try {
      await cameraControllerInstance.value!.resumeVideoRecording();
    } on CameraException catch (e) {
      log('Error resuming video recording: $e');
    }
  }

  // TODO <><><><><><><><><> For Saving Video Recording <><><><><><><><>
  Future<void> savingVideoRecording() async {
    if (isRecordingInProgress.value) {
      XFile? rawVideo = await stopVideoRecording();
      File videoFile = File(rawVideo!.path);

      int currentUnix = DateTime.now().millisecondsSinceEpoch;

      final directory = await getApplicationDocumentsDirectory();
      String fileFormat = videoFile.path.split('.').last;

      captureVideo.value =
          await videoFile.copy('${directory.path}/$currentUnix.$fileFormat');
      update();
    } else {
      await startVideoRecording();
    }
  }

  void toggleFlashMode() {
    if (currentFlashMode.value != null) {
      FlashMode nextFlashMode;
      switch (currentFlashMode.value) {
        case FlashMode.off:
          nextFlashMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          nextFlashMode = FlashMode.always;
          break;
        case FlashMode.always:
          nextFlashMode = FlashMode.torch;
          break;
        case FlashMode.torch:
          nextFlashMode = FlashMode.off;
          break;
        default:
          nextFlashMode = FlashMode.off;
      }
      _setFlashMode(nextFlashMode);
    }
  }

  void switchCamera() {
    isCameraInitialized.value = false;
    onNewCameraSelected(
      cameras[isRearCameraSelected.value ? 0 : 1],
    );
    isRearCameraSelected.toggle();
  }

  Future<void> captureImageAndSave() async {
    await takePicture();
    if (captureImage.value != null) {
      int currentUnix = DateTime.now().millisecondsSinceEpoch;
      final directory = await getApplicationDocumentsDirectory();
      String fileFormat = captureImage.value!.path.split('.').last;
      captureImage.value = await captureImage.value!
          .copy('${directory.path}/$currentUnix.$fileFormat');
      Get.to(StoryDesigner(filePath: captureImage.value!.path));
      update(); // Trigger UI update
    }
  }

  IconData getFlashIcon(FlashMode? flashMode) {
    switch (flashMode) {
      case FlashMode.off:
        return FluentIcons.flash_off_20_regular;
      case FlashMode.auto:
        return FluentIcons.flash_auto_20_regular;
      case FlashMode.always:
        return FluentIcons.flash_20_regular;
      case FlashMode.torch:
        return FluentIcons.flashlight_20_regular;
      default:
        return FluentIcons.flash_off_20_regular;
    }
  }
}
