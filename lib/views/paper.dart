import 'package:flutter/material.dart';

class Paper extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintGrey = Paint()..color = Colors.grey;
    var rectRed = RRect.fromLTRBR(
        0, 0, size.width, size.height, const Radius.circular(8.0));
    canvas.drawRRect(rectRed, paintGrey);

    final paintWhite = Paint()..color = Colors.yellow.shade50;
    var rectWhite =
        RRect.fromLTRBR(5, 0, size.width, size.height, const Radius.circular(8.0));
    canvas.drawRRect(rectWhite, paintWhite);

    final paintDarkGrey = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 1.0;

    for(double i = 24;i < size.height;i+= 24)
      {
        canvas.drawLine(Offset(0, i),
            Offset(size.width,  i), paintDarkGrey);
      }

    final paintPink = Paint()
      ..color = Colors.pinkAccent
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset(size.width * .1, 0),
        Offset(size.width * .1, size.height), paintPink);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
