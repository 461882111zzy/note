import 'package:dailyflowy/app/data/task.dart';
import 'package:fluent_ui/fluent_ui.dart' as ui;
import 'package:flutter/material.dart';

Color getPriorityColor(Priority priority) {
  const wording = [Colors.orange, Colors.blue, Colors.red];
  return wording[priority.index];
}

Color getTaskStatusColor(TaskStatus taskStatus, BuildContext context) {
  final theme = ui.FluentTheme.of(context).accentColor;
  var colors = [
    Colors.grey,
    const Color.fromARGB(255, 244, 177, 61),
    theme,
    Colors.red
  ];

  return colors[taskStatus.index];
}
