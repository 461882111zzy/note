import 'dart:async';
import 'dart:io';

import 'package:dailyflowy/app/modules/0_home/controllers/home_controller.dart';
import 'package:dailyflowy/app/views/widgets/move_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../app_window.dart';
import 'mouse_hover_builder.dart';

class TitleBar extends StatefulWidget {
  const TitleBar({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TitleBarState();
  }
}

class _TitleBarState extends State<TitleBar> {
  StreamSubscription<bool>? close;
  StreamSubscription<bool>? close1;
  @override
  void initState() {
    super.initState();
    close = Get.find<AppWindow>().isFullScreen.listen((value) {
      setState(() {});
    });

    close1 = Get.find<HomeController>().isMiniMode.listen((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    close?.cancel();
    close1?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appWindow = Get.find<AppWindow>();
    final isMiniMode = Get.find<HomeController>().isMiniMode.value;
    return MoveWindowDetector(
        child: Container(
      height: 32,
      color: const Color.fromARGB(255, 29, 27, 27),
      child: Row(
        children: [
          if (Platform.isWindows)
            Image.asset(
              'images/APPC.png',
              width: 16,
            ).marginOnly(left: 7, right: 5),
          if (Platform.isWindows)
            const Text('DailyFlowy',
                style: TextStyle(fontSize: 12, color: Colors.white)),
          const Spacer(),
          _buildHoverButton(
              isMiniMode == false
                  ? CupertinoIcons.fullscreen_exit
                  : CupertinoIcons.fullscreen,
              Colors.grey.withOpacity(0.2), () {
            Get.find<HomeController>().changeMode();
          }),
          if (Platform.isWindows)
            _buildHoverButton(
                CupertinoIcons.minus, Colors.grey.withOpacity(0.2), () {
              appWindow.minimize();
            }),
          if (Platform.isWindows)
            _buildHoverButton(
                appWindow.isFullScreen.value == true
                    ? Icons.copy
                    : Icons.crop_square,
                Colors.grey.withOpacity(0.2), () {
              appWindow.triggermaximize();
            }),
          if (Platform.isWindows)
            _buildHoverButton(CupertinoIcons.clear, Colors.red, () {
              appWindow.close();
            }),
        ],
      ),
    ));
  }

  Widget _buildHoverButton(
      IconData icon, Color color, void Function() onClick) {
    return MouseHoverBuilder(builder: (context, entered) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        color: entered ? color : Colors.transparent,
        onPressed: onClick,
        borderRadius: const BorderRadius.all(Radius.circular(0.0)),
        child: Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
      );
    });
  }
}
