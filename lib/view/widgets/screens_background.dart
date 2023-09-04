import 'package:flutter/material.dart';

class ScreenBackgoundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var center = Offset.zero;
    var radius = 100.0;
    var paint = Paint()
      ..color = Color(0xFFFDC839).withOpacity(0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 2);

    canvas.drawCircle(center, radius, paint);
    var positon = Offset(size.width, 0);
    var paint2 = Paint()
      ..color = Color(0xFF906FFF).withOpacity(0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 2);
    canvas.drawCircle(positon, radius, paint2);
    var positon3 = Offset(0, size.height + radius);
    var paint3 = Paint()
      ..color = Color(0x29ff5fe0)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 4);
    canvas.drawCircle(positon3, radius * 2, paint3);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
