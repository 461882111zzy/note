import 'dart:async';

import 'package:dailyflowy/app/controllers/calendar_controller.dart';
import 'package:dailyflowy/app/controllers/task_controller.dart';
import 'package:dailyflowy/app/data/meeting.dart';
import 'package:dailyflowy/app/data/task.dart';
import 'package:dailyflowy/app/views/colors_util.dart';
import 'package:dailyflowy/app/views/task/edit_task.dart';
import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fluent_ui/fluent_ui.dart' as ui;

class DueDateActivityWidget extends StatefulWidget {
  const DueDateActivityWidget({super.key});

  @override
  State<DueDateActivityWidget> createState() => _DueDateActivityWidgetState();
}

class _DueDateActivityWidgetState extends State<DueDateActivityWidget> {
  TaskController taskUpController = Get.find<TaskController>();
  List<Task> _tasks = [];
  StreamSubscription<int>? _close;
  List<Meeting>? _dueMeeting;

  @override
  void initState() {
    super.initState();
    _close = taskUpController.updateTime.stream.listen((event) {
      _tasks.clear();
      fetchRecentTaskData();
    });
    fetchRecentTaskData();
  }

  @override
  void dispose() {
    _close?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ui.FluentTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next',
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.bold, fontSize: 19.px),
        ).marginOnly(bottom: 13.px),
        if (_tasks.isEmpty)
           Text(
            'No Upcoming Task',
            style: TextStyle(color: theme.typography.subtitle!.color, fontSize: 12),
          ).marginOnly(left: 10),
        if (_tasks.isNotEmpty)
          Wrap(
              spacing: 13.px,
              runSpacing: 13.px,
              children: _tasks.map((e) {
                return MouseRegionBuilder(builder: (context, entered) {
                  final color = getPriorityColor(e.priority);
                  final dueDate = _findDueDate(e);
                  final dif = dueDate?.difference(
                      DateTime.now().subtract(const Duration(days: 1)));
                  return GestureDetector(
                    onTap: () {
                      showTaskEditDialog(context, e);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x3F6674C4),
                            offset: Offset(0.px, 4.px),
                            blurRadius: 12.px,
                          ),
                        ],
                      ),
                      child: Container(
                        width: 200,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: getPriorityColor(e.priority).withAlpha(30),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.title,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(color: color),
                                  ).marginOnly(right: 0),
                                  if (dueDate != null)
                                    Text(
                                      '到期日:${DateFormat.MMMd().format(dueDate)}',
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.black54),
                                    ),
                                  if (dueDate != null)
                                    Text(
                                      '还剩${dif!.inDays}天',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black87),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
              }).toList()),
      ],
    ).marginOnly(left: 0, right: 27.px, top: 38.px);
  }

  void fetchRecentTaskData() async {
    final calendarController = Get.find<CalendarController>();

    //提前5天提醒
    final now = DateTime.now();
    List<Meeting>? dueMeeting = await calendarController.findMeetingsByDate(
        now, now.add(const Duration(days: 7)));

    List<int> tasks = [];
    dueMeeting?.removeWhere((element) => element.taskId == null);
    dueMeeting?.forEach((element) {
      if (element.taskId != null) {
        tasks.add(element.taskId!);
      }
    });

    final taskUpController = Get.find<TaskController>();
    _tasks = await taskUpController.findTasks(tasks) ?? [];
    _tasks.removeWhere((val) {
      return val.taskStatus == TaskStatus.delete ||
          val.taskStatus == TaskStatus.done;
    });

    _dueMeeting = dueMeeting;
    setState(() {});
  }

  DateTime? _findDueDate(Task task) {
    try {
      final meeting = _dueMeeting
          ?.firstWhere((element) => (element.id == task.dueDateMeetingId));
      return meeting!.from ?? meeting.to;
    } catch (e) {
      return null;
    }
  }
}
