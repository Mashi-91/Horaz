import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:horaz/utils/CameraUtils/CustomCameraController.dart';

import '../config/export.dart';

class AnimatedBorderButton extends StatefulWidget {
  final double size;

  const AnimatedBorderButton({
    Key? key,
    required this.size
  }) : super(key: key);

  @override
  _AnimatedBorderButtonState createState() => _AnimatedBorderButtonState();
}

class _AnimatedBorderButtonState extends State<AnimatedBorderButton> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<CustomCameraController>();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // Adjust duration as needed
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear, // Use a different curve for smoother animation if needed
      ),
    );

    _controller.forward().whenComplete(() {
      controller.stopVideoRecording();
    }); // Repeat the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: widget.size,
              width: widget.size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white30,
              ),
            ),
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: BorderPainter(animationValue: _animation.value),
            ),
            Icon(
              Icons.circle,
              color: Colors.red,
              size: widget.size * 0.6,
            )
          ],
        );
      },
    );
  }
}


class BorderPainter extends CustomPainter {
  final double animationValue;

  BorderPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final double radius = size.width / 2;
    final double arcAngle = 2 * pi * animationValue;

    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: radius),
      -pi / 2,
      arcAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
