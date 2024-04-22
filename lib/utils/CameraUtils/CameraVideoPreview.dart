import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:horaz/config/export.dart';
import 'package:horaz/models/StoryModel.dart';
import 'package:horaz/screens/ChatScreen/chat_export.dart';
import 'package:logger/logger.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_trimmer/video_trimmer.dart';

class CameraVideoPreview extends StatefulWidget {
  final File file;

  const CameraVideoPreview({Key? key, required this.file}) : super(key: key);

  @override
  State<CameraVideoPreview> createState() => _CameraVideoPreviewState();
}

class _CameraVideoPreviewState extends State<CameraVideoPreview> {
  final Trimmer _trimmer = Trimmer();
  var startValue = 0.0;
  var endValue = 0.0;
  var isPlaying = false;
  Duration? videoDuration;

  @override
  void initState() {
    super.initState();
    initTrimmer();
  }

  void initTrimmer() async {
    await _trimmer.loadVideo(videoFile: File(widget.file.path));
    videoDuration = _trimmer.videoPlayerController!.value.duration;
    setState(() {});
  }

  Future saveVideo() async {
    try {
      await _trimmer.saveTrimmedVideo(
        startValue: startValue,
        endValue: endValue,
        onSave: (String? outputPath) async {
          if (outputPath != null) {
            await saveMediaToFirebaseStorage(File(outputPath));
            Get.offAllNamed(AppRoutes.homeNavigationScreen);
          }
        },
      );
    } catch (e) {
      log('Failed to export video: $e');
    }
  }

  Future<void> saveMediaToFirebaseStorage(File file) async {
    try {
      final storyCollection = FirebaseFirestore.instance.collection('stories');
      final fileName = file.path.split('/').last;
      final currentUser = FirebaseAuth.instance.currentUser;

      // Generate thumbnail
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: file.path,
        imageFormat: ImageFormat.JPEG,
        quality: 30,
      );

      // Upload video file
      final videoRef = FirebaseStorage.instance
          .ref()
          .child('stories/${currentUser!.uid}/$fileName');
      final videoUploadTask = await videoRef.putFile(file);
      final videoDownloadURL = await videoUploadTask.ref.getDownloadURL();

      // Upload thumbnail image
      final thumbnailRef = FirebaseStorage.instance
          .ref()
          .child('stories/${currentUser.uid}/thumbnails/$fileName.jpg');
      final thumbnailUploadTask =
      await thumbnailRef.putData(thumbnail!, SettableMetadata(contentType: 'image/jpeg'));
      final thumbnailDownloadURL = await thumbnailUploadTask.ref.getDownloadURL();

      final storyItem = StoryModel(
        userName: currentUser.displayName.toString(),
        userImage: currentUser.photoURL.toString(),
        userId: currentUser.uid,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        story: StoryItem(
          media: StoryMediaType.video,
          duration: videoDuration,
          storyUrl: videoDownloadURL,
          videoThumbnail: thumbnailDownloadURL,
        ),
      );

      // Add the story as a new document in the collection
      await storyCollection.add(storyItem.toJson());

    } catch (e) {
      Logger().e('Error saving media to Firebase: $e');
    }
  }

  Future<void> startVideo() async {
    final videoPlaybackValue = await _trimmer.videoPlaybackControl(
      startValue: startValue,
      endValue: endValue,
    );
    isPlaying = videoPlaybackValue;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1B1C20),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(10),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xff1B1C20),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Size screenSize = MediaQuery.of(context).size;
            return Stack(
              children: [
                Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_trimmer.currentVideoFile != null) ...[
                      Positioned.fill(
                        bottom: screenSize.height / 12,
                        child: VideoViewer(trimmer: _trimmer),
                      ),
                      Positioned(
                        top: screenSize.height / 32,
                        left: 0,
                        right: 0,
                        child: TrimViewer(
                          trimmer: _trimmer,
                          durationStyle: DurationStyle.FORMAT_MM_SS,
                          maxVideoLength: Duration(
                            seconds: _trimmer.videoPlayerController!.value
                                .duration.inSeconds,
                          ),
                          onChangeStart: (val) {
                            startValue = val;
                            setState(() {});
                          },
                          onChangeEnd: (val) {
                            endValue = val;
                            setState(() {});
                          },
                          onChangePlaybackState: (val) {
                            isPlaying = val;
                            setState(() {});
                          },
                          viewerWidth: screenSize.width,
                          editorProperties: const TrimEditorProperties(
                            borderPaintColor: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        bottom: 0,
                        top: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(154),
                          child: InkWell(
                            onTap: () {
                              startVideo();
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black26,
                              ),
                              child: isPlaying
                                  ? const Icon(
                                      Icons.pause,
                                      color: Colors.white,
                                      size: 30,
                                    )
                                  : const Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: screenSize.height / 6,
                    width: screenSize.width,
                    color: Colors.black45,
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: InkWell(
                      onTap: () async {
                        await saveVideo();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(Icons.arrow_forward),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
