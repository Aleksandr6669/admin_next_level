import 'package:flutter/material.dart';

class ParallaxBackground extends StatefulWidget {
  final Widget child;
  final String backgroundImage;

  const ParallaxBackground({
    super.key,
    required this.child,
    required this.backgroundImage,
  });

  @override
  _ParallaxBackgroundState createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends State<ParallaxBackground> {
  double? _x;
  double? _y;

  // The effect strength. Lower value means less movement.
  final double _panFactor = 4;
  final double _zoomFactor = 1.05;
  final int _animationDurationMs = 500;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    double translateX = 0;
    double translateY = 0;

    if (_x != null && _y != null) {
      final normalizedX = ((_x! - screenSize.width / 2) / (screenSize.width / 2));
      final normalizedY = ((_y! - screenSize.height / 2) / (screenSize.height / 2));

      // Translate the image in the OPPOSITE direction of the mouse.
      translateX = -normalizedX * _panFactor;
      translateY = -normalizedY * _panFactor;
    }

    return MouseRegion(
      onHover: (event) {
        setState(() {
          _x = event.position.dx;
          _y = event.position.dy;
        });
      },
      onExit: (event) {
        setState(() {
          _x = null;
          _y = null;
        });
      },
      child: Stack(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: _animationDurationMs),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(translateX, translateY, 0),
            transformAlignment: Alignment.center,
            child: Transform.scale(
              scale: _zoomFactor,
              child: SizedBox(
                width: screenSize.width,
                height: screenSize.height,
                child: Image.asset(
                  widget.backgroundImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}
