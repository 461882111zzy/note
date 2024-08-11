import 'package:dailyflowy/app/controllers/utils.dart';
import 'package:dailyflowy/app/data/task.dart';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as ui;

import '../data/meeting.dart';
import 'widgets/mouse_region_builder.dart';
import 'utils.dart';

class DueDateWidget extends StatelessWidget {
  final Meeting? due;
  final Task task;
  final void Function(Meeting? due)? onDueChanged;
  const DueDateWidget(
      {Key? key, this.due, this.onDueChanged, required this.task})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ui.FluentTheme.of(context);
    return MouseRegionBuilder(builder: (context, entered) {
      return GestureDetector(
        onTap: () async {
          final date = await showDatePickerEx(
              context,
              initDate: due != null ? due!.to! : DateTime.now(),
             );
          if (date == null) {
            return;
          }
          final meeting = await setTaskDueDate(task, date);
          onDueChanged!(meeting);
        },
        child: due != null
            ? SizedBox(
                width: 30,
                height: 14,
                child: Center(
                  child: Text(
                    '${due!.to!.month}-${due!.to!.day}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        height: 0.8, fontSize: 10, color: theme.accentColor),
                  ),
                ),
              )
            : Icon(
                Icons.calendar_today,
                color: theme.accentColor,
                size: 14,
              ),
      );
    });
  }
}
