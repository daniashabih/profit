import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ProFitLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final double fontSize;
  final bool isHorizontal;
  final Color? textColor;

  const ProFitLogo({
    super.key,
    this.size = 64,
    this.showText = true,
    this.fontSize = 28,
    this.isHorizontal = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = textColor ?? (isDark ? Colors.white : const Color(0xFF0F172A));

    final iconWidget = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161A20) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(
          color: AppColors.primaryLime.withOpacity(0.8),
          width: size > 48 ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLime.withOpacity(0.25),
            blurRadius: size * 0.4,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _PulseBarbellPainter(color: AppColors.primaryLime),
      ),
    );

    if (!showText) {
      return iconWidget;
    }

    final textWidget = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Fit',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: primaryColor,
          ),
        ),
        Text(
          'Flow',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: AppColors.primaryLime,
          ),
        ),
      ],
    );

    if (isHorizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconWidget,
          SizedBox(width: size * 0.25),
          textWidget,
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconWidget,
        SizedBox(height: size * 0.2),
        textWidget,
      ],
    );
  }
}

class _PulseBarbellPainter extends CustomPainter {
  final Color color;

  _PulseBarbellPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    final barPaint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;

    // Horizontal center connector bar
    canvas.drawLine(
      Offset(size.width * 0.15, centerY),
      Offset(size.width * 0.85, centerY),
      barPaint,
    );

    // 4 vertical pulse bars: outer shorter, inner taller
    final barWidth = size.width * 0.14;

    // Outer Left bar
    _drawRoundedBar(
      canvas,
      paint,
      centerX: size.width * 0.18,
      centerY: centerY,
      width: barWidth,
      height: size.height * 0.55,
    );

    // Inner Left bar (taller)
    _drawRoundedBar(
      canvas,
      paint,
      centerX: size.width * 0.38,
      centerY: centerY,
      width: barWidth,
      height: size.height * 0.95,
    );

    // Inner Right bar (taller)
    _drawRoundedBar(
      canvas,
      paint,
      centerX: size.width * 0.62,
      centerY: centerY,
      width: barWidth,
      height: size.height * 0.95,
    );

    // Outer Right bar
    _drawRoundedBar(
      canvas,
      paint,
      centerX: size.width * 0.82,
      centerY: centerY,
      width: barWidth,
      height: size.height * 0.55,
    );
  }

  void _drawRoundedBar(
    Canvas canvas,
    Paint paint, {
    required double centerX,
    required double centerY,
    required double width,
    required double height,
  }) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: width,
        height: height,
      ),
      Radius.circular(width / 2),
    );
    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
