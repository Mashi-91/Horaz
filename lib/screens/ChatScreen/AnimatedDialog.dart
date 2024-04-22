import 'package:flutter/material.dart';

class AnimatedDialog extends StatefulWidget {
  final Offset buttonPosition;
  final Widget child;

  const AnimatedDialog(
      {Key? key, required this.buttonPosition, required this.child})
      : super(key: key);

  @override
  _AnimatedDialogState createState() => _AnimatedDialogState();
}

class _AnimatedDialogState extends State<AnimatedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    scaleAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastLinearToSlowEaseIn,
      reverseCurve: Curves.fastEaseInToSlowEaseOut,
    );

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 100,
          left: 8,
          child: AnimatedBuilder(
            animation: scaleAnimation,
            builder: (BuildContext context, Widget? child) {
              return Transform(
                transform: Matrix4.translationValues(
                  0.0,
                  widget.buttonPosition.dy * (1 - scaleAnimation.value),
                  0.0,
                ),
                child: child,
              );
            },
            child: Material(
              color: Colors.transparent,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: Container(
                  // padding: EdgeInsets.all(40),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
