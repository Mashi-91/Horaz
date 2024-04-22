import 'dart:async';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:horaz/screens/ChatScreen/chat_export.dart';
import 'package:horaz/screens/StoryScreen/VideoPlayerWidget.dart';
import 'package:intl/intl.dart';
import 'package:horaz/models/StoryModel.dart';

class StoryViewFullScreen extends StatefulWidget {
  final List<StoryModel> storyModel;

  const StoryViewFullScreen({Key? key, required this.storyModel})
      : super(key: key);

  @override
  _StoryViewFullScreenState createState() => _StoryViewFullScreenState();
}

class _StoryViewFullScreenState extends State<StoryViewFullScreen> {
  final CarouselController _controller = CarouselController();
  int _currentIndex = 0;
  // Timer? _timer;
  // late List<double> _progressValues;

  @override
  void initState() {
    super.initState();
    // _progressValues = List<double>.filled(widget.storyModel.length, 0.0);
    // _startTimer();
  }

  @override
  void dispose() {
    // _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    // const duration = Duration(seconds: 1); // Adjust the duration as needed
    // _timer = Timer.periodic(duration, (Timer timer) {
    //   if (_progressValues[_currentIndex] >= 1.0) {
    //     timer.cancel();
    //     _nextStory();
    //   } else {
    //     setState(() {
    //       _progressValues[_currentIndex] += 1.0; // Adjust this value as needed
    //     });
    //   }
    // });
  }

  void _nextStory() {
    if (_currentIndex < widget.storyModel.length - 1) {
      _controller.nextPage();
      setState(() {
        _currentIndex++;
        // _progressValues[_currentIndex] = 0.0;
      });
      _startTimer();
    } else {
      // Implement logic to navigate to the next screen or perform any action
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      _controller.previousPage();
      setState(() {
        _currentIndex--;
        // _progressValues[_currentIndex] = 0.0;
      });
      _startTimer();
    } else {
      // Implement logic to go to the previous screen or perform any action
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.storyModel.isEmpty) {
      return const Center(
        child: Text(
          'No stories available.',
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      return GestureDetector(
        onTapUp: (TapUpDetails details) {
          final double screenWidth = MediaQuery.of(context).size.width;
          if (details.localPosition.dx < screenWidth / 2) {
            // Tapped on the left side of the screen
            // _previousStory();
          } else {
            // Tapped on the right side of the screen
            // _nextStory();
          }
        },
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: CarouselSlider.builder(
            carouselController: _controller,
            itemCount: widget.storyModel.length,
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height / 1.1,
              aspectRatio: 21 / 9,
              viewportFraction: 0.9,
              autoPlay: false,
              enableInfiniteScroll: false,
              onPageChanged: (index, _) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            itemBuilder: (context, index, _) {
              final storyCreatedAt = widget.storyModel[index].createdAt;
              return Padding(
                padding: const EdgeInsets.only(top: 12, right: 16),
                child: _buildStoryItem(
                  widget.storyModel[index],
                  storyCreatedAt.toString(),
                  index,
                ),
              );
            },
          ),
        ),
      );
    }
  }

  Widget _profileTile(
      {required String imageUrl, required String name, required String time}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(imageUrl),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {},
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.download_rounded,
                color: Colors.blue,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {},
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.share,
                size: 18,
                color: Colors.blue,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStoryItem(StoryModel story, String time, int index) {
    if (story.story.storyUrl!.contains('.mp4')) {
      return _buildVideoPlayer(story.story.storyUrl!, index);
    } else {
      return _buildImage(story.story.storyUrl!, time, index);
    }
  }

  Widget _buildVideoPlayer(String videoUrl, int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VideoPlayerWidget(videoUrl: videoUrl),
        const SizedBox(height: 8),
        _profileTile(
          imageUrl: widget.storyModel[index].userImage,
          name: widget.storyModel[index].userName,
          time: DateFormat('h:mm a').format(DateTime.now()),
        ),
      ],
    );
  }

  Widget _buildImage(String imageUrl, String time, int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 1.26,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _profileTile(
          imageUrl: widget.storyModel[index].userImage,
          name: widget.storyModel[index].userName,
          time: time,
        ),
      ],
    );
  }
}
