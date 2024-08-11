import 'package:dailyflowy/app/data/workspace.dart';
import 'package:dailyflowy/app/modules/2_taskboard/views/task_list_view.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:fluent_ui/fluent_ui.dart' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'link_list.dart';
import 'notes_list_widget.dart';

// Widget for displaying task details
class TaskDetailsWidget extends StatefulWidget {
  final FolderData? folderData; // Folder data for the task
  final int timestamp; // Timestamp for the task
  const TaskDetailsWidget(
      {super.key, required this.folderData, required this.timestamp});

  @override
  State<TaskDetailsWidget> createState() => _TaskDetailsWidgetState();
}

class _TaskDetailsWidgetState extends State<TaskDetailsWidget>
    with SingleTickerProviderStateMixin {
  final List<String> _tabs = ['任务', '链接', '笔记']; // List of tab names
  int currentIndex = 0;

  @override
  void initState() {
    // Initialize the tab controller
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        //  _buildTopbar(),
        Expanded(
          child: _buildTabView() // Build the board view
              .marginOnly(left: 0, right: 0, bottom: 20),
        )
      ],
    );
  }

  List<ui.Tab> generateTab() {
    final theme = ui.FluentTheme.of(context);
    final lists = [
      TaskListView(
        timestamp: widget.timestamp,
        folderData: widget.folderData,
      ),
      AssetsWidget(
        folderData: widget.folderData!,
      ),
      NotesWidget(
        folderData: widget.folderData!,
      )
    ];

    Color getColor(int index) {
      return currentIndex == index ? theme.accentColor : theme.inactiveColor.withOpacity(0.5);
    }

    var icons = [
      Icon(ui.FluentIcons.task_list, color: getColor(0)),
      Icon(ui.FluentIcons.link12, color: getColor(1)),
      Icon(ui.FluentIcons.class_notebook_logo16, color: getColor(2)),
    ];

    return List<ui.Tab>.generate(_tabs.length, (index) {
      return ui.Tab(
        text: Text(
          _tabs[index],
          style: TextStyle(color: getColor(index)),
        ),
        semanticLabel: _tabs[index],
        icon: icons[index],
        body: lists[index],
      );
    });
  }

  Widget _buildTabView() {
    final theme = ui.FluentTheme.of(context);
    return ui.TabView(
      tabs: generateTab(),
      currentIndex: currentIndex,
      onChanged: (index) => setState(() => currentIndex = index),
      tabWidthBehavior: ui.TabWidthBehavior.sizeToContent,
      header: Row(
        children: [
          Icon(
            Icons.folder_open,
            color: theme.accentColor,
          ).marginOnly(right: 10),
          Text(_buildTitle(),
                  style: theme.typography.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.accentColor,
                      fontSize: 18.px))
              .marginOnly(right: 10),
              const ui.Divider(direction: Axis.vertical),
        ],
      ),
      minTabWidth: 200,
      closeButtonVisibility: ui.CloseButtonVisibilityMode.never,
      showScrollButtons: false,
    );
  }

  // Build the title for the task
  String _buildTitle() {
    if (widget.folderData == null) {
      return '';
    }
    return ' ${widget.folderData!.title}';
  }
}
