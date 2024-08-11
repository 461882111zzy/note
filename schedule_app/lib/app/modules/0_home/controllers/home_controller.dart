import 'package:dailyflowy/app/modules/2_taskboard/views/index_view2.dart';
import 'package:dailyflowy/app/views/app_window.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  RxBool isMiniMode = false.obs;

  Rect normalModeRect = Rect.fromLTWH(0, 0, 1280.px, 868.px);
  Rect? miniModeRect;

  final Rx<ThemeMode> _mode = ThemeMode.system.obs;

  LocateController locateController = LocateController();
  TabController? _tabController;

  Future<void> initialize() async {
    return loadThemeModeFromSp();
  }

  set tabController(TabController? tabController) {
    _tabController = tabController;
  }

  TabController get tabController => _tabController!;

  ThemeMode get mode => _mode.value;
  set mode(ThemeMode mode) {
    _mode.update((val) {
      _mode.value = mode;
      saveThemeModeToSp();
    });
  }

  Rx<ThemeMode> getRxThemeMode() => _mode;

  Future<void> loadThemeModeFromSp() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final modeIndex = sharedPreferences.getInt('theme_mode') ?? 0;
    mode = ThemeMode.values[modeIndex];
  }

  void saveThemeModeToSp() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt('theme_mode', mode.index);
  }

  void changeMode() {
    if (isMiniMode.value) {
      setNormalMode();
    } else {
      setMiniMode();
    }
  }

  void setMiniMode() {
    isMiniMode.update((val) async {
      await cacheWindowProp();
      isMiniMode.value = true;
      setWindowProp();
    });
  }

  Future cacheWindowProp() async {
    final rect = await Get.find<AppWindow>().getBounds();
    if (isMiniMode.isFalse) {
      normalModeRect = rect;
    } else {
      miniModeRect = rect;
    }
  }

  void setWindowProp() async {
    final app = Get.find<AppWindow>();
    if (isMiniMode.isFalse) {
      await app.setMinSize(Size(1280.px, 868.px));
      app.setBounds(normalModeRect);
      app.setAlwaysOnBottom(false);
      app.setHasShadow(true);
    } else {
      await app.setMinSize(Size(280.px, 400.px));

      if (miniModeRect == null) {
        await app.setSize(Size(280.px, 400.px));
        await app.setTopRight();
      } else {
        app.setBounds(miniModeRect!);
      }
      app.setHasShadow(false);
      app.setAlwaysOnBottom(true);
    }
  }

  void setNormalMode() {
    isMiniMode.update((val) async {
      await cacheWindowProp();
      isMiniMode.value = false;
      setWindowProp();
    });
  }
}
