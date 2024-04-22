import 'package:flutter/material.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/utils/AppUtils.dart';
import 'dart:math' as math;

import 'package:horaz/widgets/CommonWidgets.dart';

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.children,
  });

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 62,
      height: 62,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: CommonWidget.buildCircleButton(
            onTap: _toggle,
            isIcon: false,
            child: Icon(Icons.close, color: AppColors.whiteColor),
            padding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 70.0 / (count - 1);
    for (var i = 0, angleInDegrees = 8.0;
        i < count;
        i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: CommonWidget.buildCircleButton(
            onTap: _toggle,
            isIcon: false,
            child: AppUtils.svgToIcon(
              iconPath: 'message-add-icon.svg',
            ),
            padding: const EdgeInsets.all(20),
            iconSize: 26,
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        // Calculate the offset based on the direction and progress
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 200.0),
          progress.value * maxDistance,
        );

        // Calculate the right and bottom positions based on the offset
        final right = 0.0 + offset.dx;
        final bottom = 0.0 + offset.dy;

        return Positioned(
          right: right,
          bottom: bottom,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: FadeTransition(
              opacity: progress,
              child: child!,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.bgColor
  });

  final Function? onPressed;
  final Color? bgColor;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return CommonWidget.buildCircleButton(
      onTap: onPressed != null ? () => onPressed!() : () {},
      isIcon: false,
      child: icon,
      // padding: const EdgeInsets.all(20),
      bgColor: bgColor,
      isShadow: true,
      isGradient: bgColor != null ? false : true,
    );
  }
}

@immutable
class FakeItem extends StatelessWidget {
  const FakeItem({
    super.key,
    required this.isBig,
  });

  final bool isBig;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      height: isBig ? 128 : 36,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: Colors.grey.shade300,
      ),
    );
  }
}
