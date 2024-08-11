import 'package:dailyflowy/app/views/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class OnWindowEvent extends WindowListener {
  late void Function() onEnteredFullScreen;
  late void Function() onLeavedFullScreen;
  late void Function() onWindowClosed;

  OnWindowEvent(
      {required this.onEnteredFullScreen,
      required this.onLeavedFullScreen,
      required this.onWindowClosed});

  @override
  void onWindowEnterFullScreen() {
    onEnteredFullScreen();
  }

  @override
  void onWindowLeaveFullScreen() {
    onLeavedFullScreen();
  }

  @override
  void onWindowClose() {
    onWindowClosed();
  }
}

/// Represents the main window of the app.
class AppWindow extends GetxController {
  RxBool isFullScreen = false.obs;

  /// Initializes the window.
  Future<void> initialize() async {
    // Don't initialize on mobile or web.
    if (defaultTargetPlatform != TargetPlatform.macOS &&
        defaultTargetPlatform != TargetPlatform.windows) {
      return;
    }

    await windowManager.ensureInitialized();
    final has = await loadPos();
    WindowOptions windowOptions = WindowOptions(
        size: !has ? Size(1280.px, 868.px) : null,
        minimumSize: Size(1280.px, 868.px),
        title: 'DailyFlowy',
        titleBarStyle: defaultTargetPlatform == TargetPlatform.macOS
            ? TitleBarStyle.hidden
            : TitleBarStyle.normal);

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    windowManager.addListener(
      OnWindowEvent(onEnteredFullScreen: () {
        isFullScreen.update((val) {
          isFullScreen.value = true;
        });
      }, onLeavedFullScreen: () {
        isFullScreen.update((val) {
          isFullScreen.value = false;
        });
      }, onWindowClosed: () async {
        //保存窗口位置到shared_preferences
        await savePos();
      }),
    );

    await Window.initialize();
  }

  Future<void> savePos() async {
    final pos = await windowManager.getBounds();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('windowLeft', pos.left);
    await prefs.setDouble('windowRight', pos.right);
    await prefs.setDouble('windowTop', pos.top);
    await prefs.setDouble('windowBottom', pos.bottom);
  }

  Future<bool> loadPos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final left = prefs.getDouble('windowLeft');
    if (left == null) return false;
    final right = prefs.getDouble('windowRight');
    final top = prefs.getDouble('windowTop');
    final bottom = prefs.getDouble('windowBottom');
    windowManager.setBounds(Rect.fromLTRB(left, top!, right!, bottom!));
    return true;
  }

  void setWindowPos(Offset position) {
    windowManager.setPosition(position);
  }

  Future<Offset> getWindowPos() {
    return windowManager.getPosition();
  }

  void minimize() {
    windowManager.minimize();
  }

  void close() async {
    await savePos();
    windowManager.close();
  }

  void triggermaximize() {
    if (isFullScreen.isFalse) {
      windowManager.setFullScreen(true);
    } else {
      windowManager.setFullScreen(false);
    }
  }

  Future<Rect> getBounds() {
    return windowManager.getBounds();
  }

  void setBounds(Rect rect) {
    windowManager.setBounds(rect);
  }

  Future<void> setMinSize(Size size) {
    return windowManager.setMinimumSize(size);
  }

  Future setTopRight() {
    return windowManager.setAlignment(Alignment.topRight, animate: true);
  }

  Future setSize(Size size) {
    return windowManager.setSize(size);
  }

  void setAlwaysOnBottom(bool isOnBottom) {
    windowManager.setAlwaysOnBottom(isOnBottom);
  }

  void setAlwaysOnTop(bool isOnTop) {
    windowManager.setAlwaysOnTop(isOnTop);
  }

  void setHasShadow(bool hasShadow) {
    windowManager.setHasShadow(hasShadow);
  }
}
