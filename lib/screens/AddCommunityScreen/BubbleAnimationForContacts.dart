import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:horaz/config/AppColors.dart';

class BubbleAnimation extends StatefulWidget {
  final VoidCallback onTap;
  String? imageUrl;
  double? left;
  double? right;
  double? imageSize;

  BubbleAnimation({
    Key? key,
    required this.onTap,
    this.imageUrl,
    this.right,
    this.left,
    this.imageSize,
  }) : super(key: key);

  @override
  _BubbleAnimationState createState() => _BubbleAnimationState();
}

class _BubbleAnimationState extends State<BubbleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Stack(
        children: [
          CircleAvatar(
            backgroundImage: widget.imageUrl != null
                ? CachedNetworkImageProvider(widget.imageUrl!)
                : null,
            radius: widget.imageSize ?? 24,
          ),
          Positioned(
            right: widget.right ?? 0,
            left: widget.left,
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: const Color(0xff857FB4),
                  child: Icon(
                    Icons.close,
                    color: AppColors.whiteColor,
                    size: 10,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
