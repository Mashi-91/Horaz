import 'package:flutter/material.dart';
import 'package:horaz/config/AppColors.dart';

class CustomToggleButton extends StatefulWidget {
  final bool isToggled;
  final double? height;
  final double? width;
  final double? elevation;
  final double? iconPositionLeftIsOn;
  final double? iconPositionLeftIsOff;
  final double? iconSize;
  final VoidCallback onTap;

  const CustomToggleButton({
    Key? key,
    required this.isToggled,
    required this.onTap,
    this.height,
    this.width,
    this.elevation,
    this.iconSize,
    this.iconPositionLeftIsOn,
    this.iconPositionLeftIsOff,
  }) : super(key: key);

  @override
  _CustomToggleButtonState createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: widget.elevation ?? 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: widget.height ?? 50.0,
          width: widget.width ?? 110.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isToggled
                  ? [
                const Color(0xff9552F5),
                AppColors.primaryColor,
                AppColors.primaryColor
              ]
                  : [AppColors.whiteColor, AppColors.whiteColor],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: widget.isToggled
                    ? widget.iconPositionLeftIsOn ?? 64.0
                    : widget.iconPositionLeftIsOff ?? 6.0,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  child: widget.isToggled
                      ? customCircleIcon(
                    iconData: Icons.notifications,
                    backgroundColor: AppColors.whiteColor,
                    iconColor: AppColors.primaryColor,
                    size: widget.iconSize,
                  )
                      : customCircleIcon(
                    iconData: Icons.notifications_off,
                    backgroundColor: AppColors.primaryColor,
                    iconColor: AppColors.whiteColor,
                    size: widget.iconSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customCircleIcon({
    required IconData iconData,
    required Color backgroundColor,
    required Color iconColor,
    double? size,
  }) {
    return CircleAvatar(
      radius: size ?? 20,
      backgroundColor: backgroundColor,
      child: Icon(
        iconData,
        color: iconColor,
        key: UniqueKey(),
      ),
    );
  }
}
