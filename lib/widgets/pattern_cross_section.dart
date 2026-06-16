import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:echoes_of_the_foundry_floor/enum/foundry_enums.dart';
import 'package:echoes_of_the_foundry_floor/utils/const.dart';

class PatternCrossSectionPainter extends CustomPainter {
  final PatternClassification classification;
  final Color color;

  PatternCrossSectionPainter({
    required this.classification,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = color.withAlpha(30)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width * 0.7;
    final h = size.height * 0.7;

    switch (classification) {
      case PatternClassification.splitPattern:
        _drawGearCrossSection(canvas, cx, cy, w * 0.45, paint, fill);
      case PatternClassification.coreBox:
        _drawCoreBoxCrossSection(canvas, cx, cy, w, h, paint, fill);
      case PatternClassification.matchPlate:
        _drawMatchPlateCrossSection(canvas, cx, cy, w, h, paint, fill);
      case PatternClassification.moldingSlick:
        _drawSlickCrossSection(canvas, cx, cy, w, h, paint);
      case PatternClassification.shrinkageRule:
        _drawRuleCrossSection(canvas, cx, cy, w, h, paint, fill);
    }
  }

  void _drawGearCrossSection(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    Paint paint,
    Paint fill,
  ) {
    final path = Path();
    const teeth = 12;
    for (int i = 0; i < teeth; i++) {
      final a1 = (i / teeth) * 2 * math.pi;
      final a2 = ((i + 0.35) / teeth) * 2 * math.pi;
      final a3 = ((i + 0.65) / teeth) * 2 * math.pi;
      final a4 = ((i + 1) / teeth) * 2 * math.pi;
      path.lineTo(cx + math.cos(a1) * r, cy + math.sin(a1) * r);
      path.lineTo(cx + math.cos(a2) * r * 1.25, cy + math.sin(a2) * r * 1.25);
      path.lineTo(cx + math.cos(a3) * r * 1.25, cy + math.sin(a3) * r * 1.25);
      path.lineTo(cx + math.cos(a4) * r, cy + math.sin(a4) * r);
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(cx, cy), r * 0.3, paint);
  }

  void _drawCoreBoxCrossSection(
    Canvas canvas,
    double cx,
    double cy,
    double w,
    double h,
    Paint paint,
    Paint fill,
  ) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: w, height: h),
      const Radius.circular(2),
    );
    canvas.drawRRect(rect, fill);
    canvas.drawRRect(rect, paint);
    final voidRect = Rect.fromCenter(
      center: Offset(cx, cy + h * 0.05),
      width: w * 0.55,
      height: h * 0.35,
    );
    canvas.drawArc(voidRect, 0, math.pi, false, paint);
    canvas.drawLine(
      Offset(voidRect.left, voidRect.center.dy),
      Offset(voidRect.right, voidRect.center.dy),
      paint,
    );
  }

  void _drawMatchPlateCrossSection(
    Canvas canvas,
    double cx,
    double cy,
    double w,
    double h,
    Paint paint,
    Paint fill,
  ) {
    final top = Rect.fromCenter(
      center: Offset(cx, cy - h * 0.22),
      width: w,
      height: h * 0.4,
    );
    final bottom = Rect.fromCenter(
      center: Offset(cx, cy + h * 0.22),
      width: w,
      height: h * 0.4,
    );
    canvas.drawRect(top, fill);
    canvas.drawRect(top, paint);
    canvas.drawRect(bottom, fill);
    canvas.drawRect(bottom, paint);
    canvas.drawLine(
      Offset(cx - w * 0.3, cy),
      Offset(cx + w * 0.3, cy),
      paint..strokeWidth = 2.0,
    );
  }

  void _drawSlickCrossSection(
    Canvas canvas,
    double cx,
    double cy,
    double w,
    double h,
    Paint paint,
  ) {
    canvas.drawLine(
      Offset(cx - w * 0.4, cy + h * 0.35),
      Offset(cx + w * 0.4, cy + h * 0.35),
      paint..strokeWidth = 2.2,
    );
    canvas.drawLine(
      Offset(cx, cy + h * 0.35),
      Offset(cx, cy - h * 0.35),
      paint..strokeWidth = 2.2,
    );
    canvas.drawLine(
      Offset(cx - w * 0.15, cy - h * 0.35),
      Offset(cx + w * 0.15, cy - h * 0.35),
      paint..strokeWidth = 2.2,
    );
  }

  void _drawRuleCrossSection(
    Canvas canvas,
    double cx,
    double cy,
    double w,
    double h,
    Paint paint,
    Paint fill,
  ) {
    final rect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: w,
      height: h * 0.25,
    );
    canvas.drawRect(rect, fill);
    canvas.drawRect(rect, paint);
    for (int i = 1; i < 6; i++) {
      final x = rect.left + (rect.width / 6) * i;
      canvas.drawLine(
        Offset(x, rect.top),
        Offset(x, rect.bottom),
        paint..strokeWidth = 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PatternCrossSectionPainter old) =>
      old.classification != classification || old.color != color;
}

Widget patternCrossSectionIcon({
  required PatternClassification classification,
  required PreservationSoundness soundness,
  double size = 36,
}) {
  final color = isDisplayOnly(soundness) ? kCoreBoxGreen : kAccent;
  return SizedBox(
    width: size,
    height: size,
    child: CustomPaint(
      painter: PatternCrossSectionPainter(
        classification: classification,
        color: color,
      ),
    ),
  );
}
