import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:dailyflowy/app/controllers/assets_controller.dart';
import 'package:dailyflowy/app/controllers/calendar_controller.dart';
import 'package:dailyflowy/app/controllers/docs_controller.dart';
import 'package:dailyflowy/app/controllers/holiday_controller.dart';
import 'package:dailyflowy/app/controllers/search_controller.dart';
import 'package:dailyflowy/app/controllers/task_controller.dart';
import 'package:dailyflowy/app/modules/0_home/controllers/home_controller.dart';
import 'package:dailyflowy/app/modules/0_home/views/home_view.dart';
import 'package:dailyflowy/app/routes/shells/open_taskboard_shell.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_core/localizations.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:get/get.dart';
import 'package:tiny_logger/tiny_logger.dart';
import 'app/controllers/line_up_controller.dart';
import 'app/controllers/message_controller.dart';
import 'app/controllers/workspace_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/url_route.dart';
import 'app/theme.dart';
import 'app/views/app_window.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.lazyPut<HomeController>(() => HomeController());
  Get.lazyPut<HolidayController>(() => HolidayController());
  Get.lazyPut<ContentSearchController>(() => ContentSearchController());
  Get.lazyPut<DocsController>(() => DocsController());
  Get.lazyPut<TaskController>(() => TaskController());
  Get.lazyPut<CalendarController>(() => CalendarController());
  Get.lazyPut<WorkSpaceController>(() => WorkSpaceController());
  Get.lazyPut<MessageController>(() => MessageController());
  Get.lazyPut<LineUpController>(() => LineUpController());
  Get.lazyPut<AssetsController>(() => AssetsController());
  Get.lazyPut<AppWindow>(() => AppWindow());
  Get.find<AppWindow>().initialize();
  Get.find<WorkSpaceController>();

  uriRoute.addShell(OpenTaskboardShell());
  log.debug('start');
  final homeController = Get.find<HomeController>();
  await homeController.initialize();
  runApp(Obx(() => FluentApp(
        title: "DailyFlowy",
        debugShowCheckedModeBanner: false,
        initialRoute: AppPages.INITIAL,
        home: const HomeView(),
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: homeController.mode,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          AppFlowyEditorLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          FluentLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          SfLocalizations.delegate,
        ],
        supportedLocales: const [Locale('zh_CN'), Locale('en')],
        locale: const Locale('en'),
      )));
}
