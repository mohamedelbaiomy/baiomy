// segmented_circular_next_button.dart
//
// A self-contained, theme-agnostic circular next button with animated
// segmented progress ring. Designed for onboarding flows.
//
// Usage:
//   SegmentedCircularNextButton(
//     currentPage: 1,
//     totalPages: 4,
//     onTap: () => controller.nextPage(...),
//   )

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A circular icon button surrounded by an animated segmented progress ring.
///
/// The ring is divided into [totalPages] segments. As [currentPage] advances,
/// segments fill with an animated transition driven internally by the widget.
///
/// All visual parameters are optional and fall back to sensible defaults so
/// the widget works with zero configuration beyond the required fields.
class BaiomySegmentedCircularNextButton extends StatefulWidget {
  const BaiomySegmentedCircularNextButton({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onTap,
    // --- Ring appearance ---
    this.ringColor,
    this.ringBackgroundColor,
    this.ringStrokeWidth = 3.0,
    this.ringGapAngle = 0.1,
    // --- Button appearance ---
    this.buttonSize = 60.0,
    this.innerButtonSize = 50.0,
    this.buttonColor,
    this.buttonShadowColor,
    this.icon = Icons.arrow_forward,
    this.iconColor = Colors.white,
    this.iconSize = 24.0,
    // --- Animation ---
    this.animationDuration = const Duration(milliseconds: 400),
    this.animationCurve = Curves.easeInOut,
  });

  /// Zero-based index of the current page.
  final int currentPage;

  /// Total number of pages (= total ring segments).
  final int totalPages;

  /// Called when the button is tapped.
  final VoidCallback onTap;

  // Ring
  /// Filled segment color. Defaults to [ColorScheme.primary].
  final Color? ringColor;

  /// Unfilled segment color. Defaults to [ringColor] at 12 % opacity.
  final Color? ringBackgroundColor;
  final double ringStrokeWidth;

  /// Gap between each segment, in radians.
  final double ringGapAngle;

  // Button
  /// Outer bounding box size (ring + button together).
  final double buttonSize;

  /// Diameter of the tappable inner circle.
  final double innerButtonSize;

  /// Inner circle fill color. Defaults to [ColorScheme.primary].
  final Color? buttonColor;

  /// Shadow color for the inner circle. Defaults to [buttonColor] at 20 % opacity.
  final Color? buttonShadowColor;
  final IconData icon;
  final Color iconColor;
  final double iconSize;

  // Animation
  final Duration animationDuration;
  final Curve animationCurve;

  @override
  State<BaiomySegmentedCircularNextButton> createState() =>
      _SegmentedCircularNextButtonState();
}

class _SegmentedCircularNextButtonState
    extends State<BaiomySegmentedCircularNextButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _progressAnim;

  // Tracks the progress value the last animation started from.
  double _previousProgress = 0.0;

  double _targetProgress(int page) => (page + 1) / widget.totalPages;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    final double initial = _targetProgress(widget.currentPage);
    _previousProgress = initial;

    _progressAnim = Tween<double>(
      begin: initial,
      end: initial,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: widget.animationCurve));
  }

  @override
  void didUpdateWidget(BaiomySegmentedCircularNextButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Re-animate whenever the page changes.
    if (oldWidget.currentPage != widget.currentPage ||
        oldWidget.totalPages != widget.totalPages) {
      _animateTo(_targetProgress(widget.currentPage));
    }
  }

  void _animateTo(double target) {
    _progressAnim = Tween<double>(
      begin: _previousProgress,
      end: target,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: widget.animationCurve));
    _animCtrl.forward(from: 0.0).whenComplete(() {
      _previousProgress = target;
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primary =
        widget.ringColor ?? Theme.of(context).colorScheme.primary;
    final Color bg = widget.ringBackgroundColor ?? primary.withAlpha(30);
    final Color btnColor = widget.buttonColor ?? primary;
    final Color shadowColor =
        widget.buttonShadowColor ?? btnColor.withAlpha(50);

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.buttonSize,
        height: widget.buttonSize,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            AnimatedBuilder(
              animation: _progressAnim,
              builder: (BuildContext context, Widget? _) => CustomPaint(
                size: Size(widget.buttonSize, widget.buttonSize),
                painter: _SegmentedRingPainter(
                  progress: _progressAnim.value,
                  totalSegments: widget.totalPages,
                  color: primary,
                  backgroundColor: bg,
                  strokeWidth: widget.ringStrokeWidth,
                  gapAngle: widget.ringGapAngle,
                ),
              ),
            ),

            Container(
              width: widget.innerButtonSize,
              height: widget.innerButtonSize,
              decoration: BoxDecoration(
                color: btnColor,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(color: shadowColor, blurRadius: 8, spreadRadius: 2),
                ],
              ),
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: widget.iconSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Internal painter — not exported; consumed only by the widget above.

class _SegmentedRingPainter extends CustomPainter {
  _SegmentedRingPainter({
    required this.progress,
    required this.totalSegments,
    required this.color,
    required this.backgroundColor,
    this.strokeWidth = 3.0,
    this.gapAngle = 0.1,
  });

  final double progress;
  final int totalSegments;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final double gapAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = (size.width - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final double totalGapAngle = gapAngle * totalSegments;
    final double availableAngle = 2 * math.pi - totalGapAngle;
    final double segmentAngle = availableAngle / totalSegments;

    final int completeSegments = (progress * totalSegments).floor();
    final double partialSegment = (progress * totalSegments) - completeSegments;

    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < totalSegments; i++) {
      final double startAngle = -math.pi / 2 + i * (segmentAngle + gapAngle);

      if (i < completeSegments) {
        // Fully filled
        paint.color = color;
        canvas.drawArc(rect, startAngle, segmentAngle, false, paint);
      } else if (i == completeSegments && partialSegment > 0) {
        // Partially filled
        paint.color = color;
        canvas.drawArc(
          rect,
          startAngle,
          segmentAngle * partialSegment,
          false,
          paint,
        );
        // Remaining background portion
        if (partialSegment < 1.0) {
          paint.color = backgroundColor;
          canvas.drawArc(
            rect,
            startAngle + segmentAngle * partialSegment,
            segmentAngle * (1.0 - partialSegment),
            false,
            paint,
          );
        }
      } else {
        // Unfilled
        paint.color = backgroundColor;
        canvas.drawArc(rect, startAngle, segmentAngle, false, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SegmentedRingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.totalSegments != totalSegments ||
      old.backgroundColor != backgroundColor ||
      old.strokeWidth != strokeWidth ||
      old.gapAngle != gapAngle;
}
