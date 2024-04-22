import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:horaz/service/HiveDBService.dart';
import 'package:horaz/utils/AppUtils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/service/DBService.dart';
import 'package:horaz/utils/CustomLoading.dart';
import 'package:horaz/widgets/CommonWidgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoViewPage extends StatefulWidget {
  VideoViewPage({super.key, required this.path, this.isFullScreen});

  final String path;
  bool? isFullScreen;

  @override
  VideoViewPageState createState() => VideoViewPageState();
}

class VideoViewPageState extends State<VideoViewPage> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  bool _showControls = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.path))
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
      });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
            setState(() {
              _showControls = !_showControls;
              _startTimer();
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              _isVideoInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(
                        _controller,
                      ),
                    )
                  : CustomLoadingIndicator.customLoadingWithoutDialog(),
              if (widget.isFullScreen ?? true)
                AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              // Navigate to full-screen video player
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenVideoPlayer(
                                    controller: _controller,
                                    tag:
                                        'video_player_${_controller.dataSource}',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.fullscreen),
                            color: Colors.white,
                            iconSize: 36,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: IconButton(
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.7)),
                    icon: _controller.value.isPlaying
                        ? const Icon(Icons.pause)
                        : const Icon(Icons.play_arrow),
                    onPressed: () {
                      setState(() {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      });
                    },
                    color: Colors.white,
                    iconSize: 36,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _showControls = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer!.cancel();
    super.dispose();
  }
}

// <><><><><><><><><><><><><><><><><> Full Screen Video Player <><><><><><><><><><><><><><><><><><><><><><><><><>

class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final String tag;

  const FullScreenVideoPlayer({required this.controller, required this.tag});

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  bool _showControls = true;

  late Timer _timer;
  late Duration _currentPosition;

  @override
  void initState() {
    super.initState();
    _currentPosition = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), _updatePosition);
    widget.controller.addListener(_onVideoPlayerStateChanged);
  }

  @override
  void dispose() {
    _timer.cancel();
    widget.controller.removeListener(_onVideoPlayerStateChanged);
    super.dispose();
  }

  void _updatePosition(Timer timer) {
    if (widget.controller.value.isPlaying) {
      setState(() {
        _currentPosition = widget.controller.value.position;
      });
    }
  }

  void _onVideoPlayerStateChanged() {
    if (!mounted) {
      return;
    }
    setState(() {
      // Update the play/pause button icon based on the video player's state
      _showControls = widget.controller.value.isPlaying ||
          widget.controller.value.isBuffering;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (bool val) {
        if (val) {
          widget.controller.pause();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: widget.tag,
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showControls = !_showControls;
                    });
                  },
                  child: VideoPlayer(widget.controller),
                ),
              ),
            ),
            Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12)
                      .copyWith(top: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.back();
                          widget.controller.pause();
                        },
                        child:
                            Icon(Icons.arrow_back, color: AppColors.whiteColor),
                      ),
                      const SizedBox(width: 10),
                      CommonWidget.buildCustomText(
                        text: 'You',
                        textStyle: TextStyle(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.share, color: AppColors.whiteColor),
                        onPressed: () {},
                      )
                    ],
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: _buildControls(),
            ),
            Positioned(
              bottom: 10.0,
              left: 0.0,
              right: 0.0,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: _buildVideoProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (widget.controller.value.isPlaying) {
                widget.controller.pause();
              } else {
                widget.controller.play();
              }
            });
          },
          child: CircleAvatar(
            radius: 34,
            backgroundColor: Colors.black.withOpacity(0.7),
            child: Icon(
              widget.controller.value.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoProgressIndicator() {
    Duration duration = widget.controller.value.duration;
    Duration position = _currentPosition;
    String currentPosition = _formatDuration(position);
    String totalDuration = _formatDuration(duration);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            currentPosition,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 200, // Specify a fixed width or adjust as needed
              child: VideoProgressIndicator(
                widget.controller,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: AppColors.primaryColor,
                ),
              ),
            ),
          ),
          Text(
            totalDuration,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
