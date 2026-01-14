import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class LiquidNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<Map<String, dynamic>> items;
  final Color selectedItemColor;
  final Color unselectedItemColor;

  const LiquidNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
    required this.selectedItemColor,
    required this.unselectedItemColor,
  });

  @override
  State<LiquidNavBar> createState() => _LiquidNavBarState();
}

class _LiquidNavBarState extends State<LiquidNavBar> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  int _previousIndex = 0;
  int _tappedIndex = -1;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.selectedIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeOut)
    );
    _scaleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scaleController.reverse();
      }
    });
  }

  @override
  void didUpdateWidget(covariant LiquidNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _previousIndex = oldWidget.selectedIndex;
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: Listenable.merge([_animationController, _scaleController]),
        builder: (context, child) {
          return CustomPaint(
            painter: _LiquidPainter(
              progress: _animation.value,
              fromIndex: _previousIndex,
              toIndex: widget.selectedIndex,
              itemCount: widget.items.length,
              color: widget.selectedItemColor.withOpacity(0.3),
              strokeColor: widget.selectedItemColor,
              scaleFactor: _scaleAnimation.value,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(widget.items.length, (index) {
                final item = widget.items[index];
                final isSelected = widget.selectedIndex == index;
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _tappedIndex = index;
                      });
                      widget.onTap(index);
                      _scaleController.forward(from: 0.0);
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: ScaleTransition(
                      scale: _tappedIndex == index
                          ? _scaleAnimation
                          : const AlwaysStoppedAnimation(1.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 28,
                            color: isSelected
                                ? widget.selectedItemColor
                                : widget.unselectedItemColor,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item['label'] as String,
                            style: TextStyle(
                              color: isSelected
                                  ? widget.selectedItemColor
                                  : widget.unselectedItemColor,
                              fontSize: 9,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

class _LiquidPainter extends CustomPainter {
  final double progress;
  final int fromIndex;
  final int toIndex;
  final int itemCount;
  final Color color;
  final Color strokeColor;
  final double scaleFactor;

  _LiquidPainter({
    required this.progress,
    required this.fromIndex,
    required this.toIndex,
    required this.itemCount,
    required this.color,
    required this.strokeColor,
    required this.scaleFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final itemWidth = size.width / itemCount;
    final fromX = itemWidth * (fromIndex + 0.5);
    final toX = itemWidth * (toIndex + 0.5);
    final y = size.height / 2;

    final stretchEffect = math.sin(progress * math.pi);

    final fillPaint = Paint()
      ..color = color.withOpacity(color.opacity * (1 - stretchEffect))
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor.withOpacity(stretchEffect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 5.0);

    final sizeMultiplier = 1.0 + (0.3 * stretchEffect);

    final baseHeight = size.height * 0.9;
    final baseWidth = baseHeight * 1.2;

    final pillHeight = baseHeight * sizeMultiplier * scaleFactor;
    final pillWidth = baseWidth * sizeMultiplier * scaleFactor;

    final currentX = fromX + (toX - fromX) * progress;

    final rect = Rect.fromCenter(
      center: Offset(currentX, y),
      width: pillWidth,
      height: pillHeight,
    );

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(pillHeight / 2));
    
    canvas.drawRRect(rrect, strokePaint);
    canvas.drawRRect(rrect, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _LiquidPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        fromIndex != oldDelegate.fromIndex ||
        toIndex != oldDelegate.toIndex ||
        itemCount != oldDelegate.itemCount ||
        color != oldDelegate.color ||
        strokeColor != oldDelegate.strokeColor ||
        scaleFactor != oldDelegate.scaleFactor;
  }
}
