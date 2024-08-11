import 'package:dailyflowy/app/views/app_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MoveWindowDetector extends StatefulWidget {
  const MoveWindowDetector({Key? key, this.child}) : super(key: key);

  final Widget? child;

  @override
  MoveWindowDetectorState createState() => MoveWindowDetectorState();
}

class MoveWindowDetectorState extends State<MoveWindowDetector> {
  double winX = 0;
  double winY = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (DragStartDetails details) {
        winX = details.globalPosition.dx;
        winY = details.globalPosition.dy;
      },
      onPanUpdate: (DragUpdateDetails details) async {
        final windowPos = await Get.find<AppWindow>().getWindowPos();
        final double dx = windowPos.dx;
        final double dy = windowPos.dy;
        final deltaX = details.globalPosition.dx - winX;
        final deltaY = details.globalPosition.dy - winY;
        Get.find<AppWindow>().setWindowPos(Offset(dx + deltaX, dy + deltaY));
      },
      child: widget.child,
    );
  }
}
