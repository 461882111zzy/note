import 'dart:async';
import 'dart:io';

import 'package:dailyflowy/app/modules/1_dashboard/views/index_view.dart'
    as dash_board;
import 'package:dailyflowy/app/modules/2_taskboard/views/index_view2.dart'
    as task_board;
import 'package:dailyflowy/app/modules/3_docboard/views/index_view.dart'
    as doc_board;

import 'package:dailyflowy/app/modules/7_calendar/views/index_view.dart'
    as calendar_board;
import 'package:dailyflowy/app/theme.dart';

import 'package:dailyflowy/app/views/meeting/appointment_dialog.dart';
import 'package:dailyflowy/app/views/task/create_task.dart';
import 'package:dailyflowy/app/views/note/docs_edit.dart';
import 'package:dailyflowy/app/views/extensions/plugin/extension_manager.dart';
import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:dailyflowy/app/views/search_widget.dart';
import 'package:dailyflowy/app/views/setting_view.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:dailyflowy/app/views/widget_extension_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart' as material;

import 'package:get/get.dart';
import 'package:tiny_logger/tiny_logger.dart';

import '../controllers/home_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late material.TabController _tabController;
  StreamSubscription<bool>? _close;
  List<NavigationPaneItem> items = [
    PaneItem(
        mouseCursor: SystemMouseCursors.click,
        icon: const Icon(FluentIcons.view_dashboard),
        title: const Text('看板'),
        body: const dash_board.IndexView(),
        onTap: () {
     
        }),
    PaneItem(
        mouseCursor: SystemMouseCursors.click,
        icon: const Icon(FluentIcons.task_manager),
        title: const Text('空间'),
        body: task_board.IndexView2(
            locateController: Get.find<HomeController>().locateController),
        onTap: () {
       
        }),
    PaneItem(
        mouseCursor: SystemMouseCursors.click,
        icon: const Icon(FluentIcons.calendar_agenda),
        title: const Text('日程'),
        body: const calendar_board.IndexView(),
        onTap: () {
       
        }),

    // PaneItem(
    //   icon: const Icon(FluentIcons.clock),
    //   title: const Text('番茄钟'),
    //   body: const pomodoro_board.IndexView(),
    // ),
    PaneItem(
        icon: const Icon(FluentIcons.class_notebook_logo16),
        title: const Text('笔记'),
        body: const doc_board.IndexView(),
        mouseCursor: SystemMouseCursors.click,
        onTap: () {
   
        }),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = material.TabController(
        vsync: this, length: items.length, animationDuration: Duration.zero);

    Get.put(HomeController()).tabController = _tabController;

    ExtensionManager.instance.initialize();

    _close = Get.find<HomeController>().isMiniMode.listen((value) {
      setState(() {});
    });

    _tabController.addListener(() {
      setState(() {});
    });

    if (Platform.isMacOS) {
      macosWidgetExt.refresh();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _close?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return material.Theme(
        data: theme.toThemeData(), child: _buildHomeView(context));
  }

  Widget _buildHomeView(BuildContext context) {
    return material.Scaffold(body: _buildBody2(context));
  }

  Widget _buildBody2(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        height: 40,
        automaticallyImplyLeading: false,
        title: Center(
          child:
              SizedBox(width: 550.px, height: 25, child: const SearchWidget()),
        ),
        actions: _buildFloatingActionButton(context),
      ),
      pane: NavigationPane(
        size: const NavigationPaneSize(openWidth: 150),
        selected: _tabController.index,
        onChanged: (index) => setState(() => _tabController.index = index),
        items: items,
        footerItems: [
          PaneItemAction(
              mouseCursor: SystemMouseCursors.click,
              icon: const Icon(material.Icons.report),
              title: const Text('日志'),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return material.Dialog(
                        child: LogView(
                          onClose: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    });
              }),
          PaneItemAction(
              icon: const Icon(FluentIcons.settings),
              title: const Text('设置'),
              mouseCursor: SystemMouseCursors.click,
              onTap: () {
                showSettingDialog(context);
              })
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTaskButton(context),
          _buildCalendarButton(context),
          _buildNoteButton(context),
        ],
      ),
    );
  }

  Widget _buildCalendarButton(BuildContext context) {
    return MouseRegionBuilder(builder: (context, _) {
      return Button(
        child: const Row(
          children: [
            material.Icon(
              material.Icons.add,
            ),
            Text(
              '日程',
              style: TextStyle(fontSize: 12),
            )
          ],
        ),
        onPressed: () async {
         
          final meeting = await editAppointmentDialog(context, meeting: null);
          if (meeting != null) {
            setState(() {});
          }
        },
      ).marginOnly(right: 16.px);
    });
  }

  Widget _buildNoteButton(BuildContext context) {
    return MouseRegionBuilder(builder: (context, _) {
      return Button(
        child: const Row(
          children: [
            material.Icon(
              material.Icons.add,
            ),
            Text(
              '笔记',
              style: TextStyle(fontSize: 12),
            )
          ],
        ),
        onPressed: () {
  
          showNoteEditDialog(context, null, null);
        },
      ).marginOnly(right: 16.px);
    });
  }

  Widget _buildTaskButton(BuildContext context) {
    return MouseRegionBuilder(builder: (context, _) {
      return Button(
        child: const Row(
          children: [
            material.Icon(
              material.Icons.add,
            ),
            Text(
              '任务',
              style: TextStyle(fontSize: 12),
            )
          ],
        ),
        onPressed: () {
       
          showTaskCreateDialog(context);
        },
      ).marginOnly(right: 16.px);
    });
  }
}
