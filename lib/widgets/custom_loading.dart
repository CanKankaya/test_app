import 'package:flutter/material.dart';
import 'dart:math';

class CustomLoader extends StatefulWidget {
  final Color color1;
  final Color color2;
  final Color color3;
  final Color color4;

  const CustomLoader({
    Key? key,
    this.color1 = Colors.amber,
    this.color2 = Colors.teal,
    this.color3 = Colors.blue,
    this.color4 = Colors.brown,
  }) : super(key: key);

  @override
  CustomLoaderState createState() => CustomLoaderState();
}

class CustomLoaderState extends State<CustomLoader> with TickerProviderStateMixin {
  late Animation<double> animation1;
  late Animation<double> animation2;
  late Animation<double> animation3;
  late Animation<double> animation4;

  late AnimationController controller1;
  late AnimationController controller2;
  late AnimationController controller3;
  late AnimationController controller4;

  @override
  void initState() {
    super.initState();

    controller1 = AnimationController(duration: const Duration(milliseconds: 5000), vsync: this);

    controller2 = AnimationController(duration: const Duration(milliseconds: 5000), vsync: this);

    controller3 = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);

    controller4 = AnimationController(duration: const Duration(milliseconds: 1250), vsync: this);

    animation1 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: controller1, curve: const Interval(0.0, 1.0, curve: Curves.elasticInOut)));

    animation2 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: controller2, curve: const Interval(0.0, 1.0, curve: Curves.linear)));

    animation3 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: controller3, curve: const Interval(0.0, 1.0, curve: Curves.linear)));

    animation4 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: controller4, curve: const Interval(0.0, 1.0, curve: Curves.linear)));

    controller1.repeat();
    controller2.repeat();
    controller3.repeat();
    controller4.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: <Widget>[
          RotationTransition(
            turns: animation1,
            child: CustomPaint(
              painter: Arc1Painter(widget.color1),
              child: const SizedBox(
                width: 150.0,
                height: 150.0,
              ),
            ),
          ),
          RotationTransition(
            turns: animation2,
            child: CustomPaint(
              painter: Arc2Painter(widget.color2),
              child: const SizedBox(
                width: 150.0,
                height: 150.0,
              ),
            ),
          ),
          RotationTransition(
            turns: animation3,
            child: CustomPaint(
              painter: Arc3Painter(widget.color3),
              child: const SizedBox(
                width: 150.0,
                height: 150.0,
              ),
            ),
          ),
          RotationTransition(
            turns: animation4,
            child: CustomPaint(
              painter: Arc4Painter(widget.color4),
              child: const SizedBox(
                width: 150.0,
                height: 150.0,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    controller4.dispose();
    super.dispose();
  }
}

class Arc1Painter extends CustomPainter {
  final Color color;

  Arc1Painter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p1 = Paint()
      ..color = color
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Rect rect1 = Rect.fromLTWH(0.0, 0.0, size.width, size.height);

    canvas.drawArc(rect1, 0.0, 0.4 * pi, false, p1);
    canvas.drawArc(rect1, 0.5 * pi, 0.4 * pi, false, p1);
    canvas.drawArc(rect1, 1.0 * pi, 0.4 * pi, false, p1);
    canvas.drawArc(rect1, 1.5 * pi, 0.4 * pi, false, p1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Arc2Painter extends CustomPainter {
  final Color color;

  Arc2Painter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p2 = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Rect rect2 = Rect.fromLTWH(0.0 + (0.2 * size.width) / 2, 0.0 + (0.2 * size.height) / 2,
        size.width - 0.2 * size.width, size.height - 0.2 * size.height);

    canvas.drawArc(rect2, 0.0, 0.4 * pi, false, p2);
    canvas.drawArc(rect2, 0.66 * pi, 0.4 * pi, false, p2);
    canvas.drawArc(rect2, 1.33 * pi, 0.4 * pi, false, p2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Arc3Painter extends CustomPainter {
  final Color color;

  Arc3Painter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p3 = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Rect rect3 = Rect.fromLTWH(0.0 + (0.4 * size.width) / 2, 0.0 + (0.4 * size.height) / 2,
        size.width - 0.4 * size.width, size.height - 0.4 * size.height);

    canvas.drawArc(rect3, 0.0, 0.8 * pi, false, p3);
    canvas.drawArc(rect3, 1.0 * pi, 0.8 * pi, false, p3);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Arc4Painter extends CustomPainter {
  final Color color;

  Arc4Painter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p4 = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Rect rect4 = Rect.fromLTWH(0.0 + (0.6 * size.width) / 2, 0.0 + (0.6 * size.height) / 2,
        size.width - 0.6 * size.width, size.height - 0.6 * size.height);

    canvas.drawArc(rect4, 0.0, 0.4 * pi, false, p4);
    canvas.drawArc(rect4, 0.66 * pi, 0.4 * pi, false, p4);
    canvas.drawArc(rect4, 1.33 * pi, 0.4 * pi, false, p4);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
