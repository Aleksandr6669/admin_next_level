import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class LiquidNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<Map<String, dynamic>> items;
  final Color selectedItemColor;
  final Color unselectedItemColor;
  final Axis direction;
  final bool extended;

  const LiquidNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
    required this.selectedItemColor,
    required this.unselectedItemColor,
    this.direction = Axis.horizontal,
    this.extended = false,
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
  final double _verticalItemHeight = 50.0;

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
      width: widget.direction == Axis.vertical ? (widget.extended ? 180 : 72) : double.infinity,
      height: widget.direction == Axis.horizontal ? 70 : double.infinity,
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
              direction: widget.direction,
              verticalItemHeight: _verticalItemHeight,
            ),
            child: widget.direction == Axis.horizontal
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _buildItems(),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: _buildItems(),
                    ),
                  ),
          );
        },
      ),
    );
  }

  List<Widget> _buildItems() {
    return List.generate(widget.items.length, (index) {
      final item = widget.items[index];
      final isSelected = widget.selectedIndex == index;
      
      Widget content = InkWell(
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
            child: widget.direction == Axis.horizontal
                ? Column(
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
                  )
                : Row(
                    mainAxisAlignment: widget.extended ? MainAxisAlignment.start : MainAxisAlignment.center,
                    children: [
                      if (widget.extended) const SizedBox(width: 20),
                      Icon(
                        item['icon'] as IconData,
                        size: 28,
                        color: isSelected
                            ? widget.selectedItemColor
                            : widget.unselectedItemColor,
                      ),
                      if (widget.extended) const SizedBox(width: 20),
                      if (widget.extended)
                        Expanded(
                          child: Text(
                            item['label'] as String,
                            style: TextStyle(
                              color: isSelected
                                  ? widget.selectedItemColor
                                  : widget.unselectedItemColor,
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
          ),
        );

      if (widget.direction == Axis.vertical) {
        return SizedBox(
          height: _verticalItemHeight,
          child: content,
        );
      }
      return Expanded(child: content);
    });
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
  final Axis direction;
  final double verticalItemHeight;

  _LiquidPainter({
    required this.progress,
    required this.fromIndex,
    required this.toIndex,
    required this.itemCount,
    required this.color,
    required this.strokeColor,
    required this.scaleFactor,
    required this.direction,
    required this.verticalItemHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (direction == Axis.horizontal) {
      _paintHorizontal(canvas, size);
    } else {
      _paintVertical(canvas, size);
    }
  }

  void _paintHorizontal(Canvas canvas, Size size) {
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

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(20));
    
    canvas.drawRRect(rrect, strokePaint);
    canvas.drawRRect(rrect, fillPaint);
  }

  void _paintVertical(Canvas canvas, Size size) {
    const double topPadding = 20.0;
    final fromY = topPadding + verticalItemHeight * (fromIndex + 0.5);
    final toY = topPadding + verticalItemHeight * (toIndex + 0.5);
    final x = size.width / 2;

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

    final baseWidth = size.width * 0.92; // Сделал шире
    final baseHeight = verticalItemHeight * 0.85;

    final pillWidth = baseWidth * sizeMultiplier * scaleFactor;
    final pillHeight = baseHeight * sizeMultiplier * scaleFactor;

    final currentY = fromY + (toY - fromY) * progress;

    final rect = Rect.fromCenter(
      center: Offset(x, currentY),
      width: pillWidth,
      height: pillHeight,
    );

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(25));
    
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
        scaleFactor != oldDelegate.scaleFactor ||
        direction != oldDelegate.direction ||
        verticalItemHeight != oldDelegate.verticalItemHeight;
  }
}
