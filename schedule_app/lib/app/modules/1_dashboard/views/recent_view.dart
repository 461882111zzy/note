import 'dart:async';

import 'package:dailyflowy/app/controllers/task_controller.dart';
import 'package:dailyflowy/app/data/task.dart';
import 'package:dailyflowy/app/views/task/edit_task.dart';
import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as ui;
import 'package:get/get.dart';

class RecentActivityWidget extends StatefulWidget {
  const RecentActivityWidget({super.key});

  @override
  State<RecentActivityWidget> createState() => _RecentActivityWidgetState();
}

class _RecentActivityWidgetState extends State<RecentActivityWidget> {
  TaskController taskUpController = Get.find<TaskController>();
  List<Task> _tasks = [];
  StreamSubscription<int>? _close;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trending',
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.bold, fontSize: 19.px),
        ).marginOnly(bottom: 13.px),
        Wrap(
            spacing: 13.px,
            runSpacing: 13.px,
            children: _tasks.map((e) {
              return MouseRegionBuilder(builder: (context, entered) {
                return GestureDetector(
                  onTap: () {
                    showTaskEditDialog(context, e);
                  },
                  child: Container(
                    width: 130,
                    height: 34,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: ui.FluentTheme.of(context).cardColor),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check,
                          size: 15,
                          color: Colors.grey,
                        ).marginOnly(left: 6, right: 6),
                        Expanded(
                          child: Text(
                            e.title,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ).marginOnly(right: 10),
                        ),
                      ],
                    ),
                  ),
                );
              });
            }).toList()),
      ],
    ).marginOnly(left: 0, right: 27.px, top: 38.px);
  }

  void fetchRecentTaskData() async {
    TaskController taskUpController = Get.find<TaskController>();
    _tasks = await taskUpController.getRecentEditedTasks() ?? [];

    if (mounted) {
      setState(() {});
    }
  }
}
