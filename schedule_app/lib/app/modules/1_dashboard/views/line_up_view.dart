import 'dart:async';

import 'package:dailyflowy/app/controllers/line_up_controller.dart';
import 'package:dailyflowy/app/controllers/task_controller.dart';
import 'package:dailyflowy/app/data/line_up.dart';
import 'package:dailyflowy/app/data/task.dart';
import 'package:dailyflowy/app/data/utils.dart';
import 'package:dailyflowy/app/views/colors_util.dart';
import 'package:dailyflowy/app/views/task/edit_task.dart';
import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:dailyflowy/app/views/widgets/selected_dialog.dart';
import 'package:dailyflowy/app/views/task/task_card.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LineUpWidget extends StatefulWidget {
  const LineUpWidget({super.key});

  @override
  State<LineUpWidget> createState() => _LineUpWidgetState();
}

class _LineUpWidgetState extends State<LineUpWidget> {
  final LineUpController _lineUpController = Get.find<LineUpController>();
  final TaskController _taskUpController = Get.find<TaskController>();
  List<Task> _tasks = [];
  List<Task> _subTasks = [];
  Map<int, Task> _mainTasks = {};
  List<LineUp> _lineups = [];
  StreamSubscription<int>? _close;
  StreamSubscription<int>? _closeTask;
  @override
  void initState() {
    super.initState();
    _close = _lineUpController.updateTime.stream.listen((event) {
      _tasks.clear();
      fetchLineUpData();
    });

    _closeTask = _taskUpController.updateTime.stream.listen((event) {
      _tasks.clear();
      fetchLineUpData();
    });

    fetchLineUpData();
  }

  @override
  void dispose() {
    _close?.cancel();
    _closeTask?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LineUp',
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.bold, fontSize: 19.px),
        ).marginOnly(bottom: 12.px),
        Wrap(
            spacing: 13.px,
            runSpacing: 13.px,
            children: _lineups.map((lineUp) {
              final e = _tasks.elementAt(_tasks.indexWhere((task) {
                return task.id == lineUp.taskId;
              }));
              return MouseRegionBuilder(builder: (context, entered) {
                return GestureDetector(
                  onTap: () {
                    showTaskEditDialog(context, e);
                  },
                  child: TaskCard(
                    title: e.title,
                    subTitle: _getMainTaskTitle(e.id),
                    color: getPriorityColor(e.priority),
                    desc: toPlainText(e.desc) ?? 'No Description',
                    onClickDelete: () {
                      _deleteLineUp(context, lineUp, e);
                    },
                    progressTotal: e.subTasks?.length,
                    progressCount: _getSubTasksCompletedCount(e.id),
                  ),
                );
              });
            }).toList()),
      ],
    ).marginOnly(left: 0, right: 27.px, top: 10.px);
  }

  Future<void> _deleteLineUp(
      BuildContext context, LineUp lineUp, Task e) async {
    final res = await showSelectedDialog(context, '提示', '确认移除么?');

    if (res == 1) {
      _lineUpController.deleteLineUp(lineUp.id);
      _lineups.remove(lineUp);
      _tasks.remove(e);
      setState(() {});
    }
  }

  void fetchLineUpData() async {
    final lineups = await _lineUpController.getAll();
    List<int> taskIds = [];
    lineups?.forEach((element) {
      if (element.taskId != null) {
        taskIds.add(element.taskId!);
      }
    });
    _lineups = lineups ?? [];
    _tasks = await _taskUpController.findTasks(taskIds) ?? [];
    setState(() {});

    _mainTasks = {};
    _subTasks = [];

    Stream taskInfo() async* {
      final tasks = <Task>[];
      tasks.addAll(_tasks);
      for (var element in tasks) {
        final mainTask = await _taskUpController.getMainTask(element);
        if (mainTask != null) {
          _mainTasks[element.id] = mainTask;
        } else if (element.subTasks != null) {
          final subTasks = await _taskUpController
              .findTasks(element.subTasks?.map((e) => e).toList());
          if (subTasks != null) _subTasks.addAll(subTasks);
        }
      }
    }

    await for (var _ in taskInfo()) {}

    setState(() {});
  }

  String _getMainTaskTitle(int id) {
    final task = _mainTasks[id];
    if (task != null) {
      return task.title;
    }
    return '';
  }

  int _getSubTasksCompletedCount(int taskId) {
    final task = _tasks.firstWhere((element) => element.id == taskId);
    int count = 0;
    if (task.subTasks != null) {
      task.subTasks?.forEach((subTask) {
        try {
          final task1 =
              _subTasks.firstWhere((element) => element.id == subTask);
          if (task1.taskStatus == TaskStatus.done) {
            count++;
          }
        } catch (e) {}
      });
    }
    return count;
  }
}
