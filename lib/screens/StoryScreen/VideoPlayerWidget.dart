import 'package:flutter/material.dart';
import 'package:horaz/config/export.dart';
import 'package:horaz/utils/CustomLoading.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({required this.videoUrl, Key? key}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _videoPlayerController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _initializeVideoPlayer();
    }
  }

  void _initializeVideoPlayer() {
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
          ..initialize().then((_) {
            if (mounted) {
              // Ensure the first frame is shown after the video is initialized
              setState(() {});
            }
          });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            _videoPlayerController.value.isInitialized
                ? SizedBox(
                    height: MediaQuery.of(context).size.height / 1.26,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: VideoPlayer(_videoPlayerController),
                    ),
                  )
                : CustomLoadingIndicator.customLoadingWithoutDialog(),
            Visibility(
              visible: _videoPlayerController.value.isPlaying,
              child: IconButton(
                icon: const Icon(Icons.pause),
                onPressed: () {
                  _videoPlayerController.pause();
                  setState(() {});
                },
              ),
            ),
            Visibility(
              visible: !_videoPlayerController.value.isPlaying,
              child: IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () {
                  _videoPlayerController.play();
                  setState(() {});
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        VideoProgressIndicator(
          _videoPlayerController,
          allowScrubbing: true,
          padding: EdgeInsets.zero,
          colors: VideoProgressColors(
            backgroundColor: Colors.grey.withOpacity(0.4),
            playedColor: Colors.white,
          ),
        )
      ],
    );
  }
}
