import 'package:dailyflowy/app/controllers/task_controller.dart';
import 'package:dailyflowy/app/controllers/workspace_controller.dart';
import 'package:dailyflowy/app/data/appointment_ex.dart';
import 'package:dailyflowy/app/views/meeting/appointment_dialog.dart';
import 'package:dailyflowy/app/views/task/edit_task.dart';
import 'package:dailyflowy/app/views/widgets/selected_dialog.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:dailyflowy/app/views/widgets/breadcrumb_bar.dart'
    as breadcrumb_bar;
import 'package:flutter/material.dart' as material;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:dailyflowy/app/controllers/calendar_controller.dart'
    as controller;

import '../../data/task.dart';
import '../../data/workspace.dart';
import '../../routes/utils.dart';

class AppointmentDetails extends StatelessWidget {
  final Appointment appointment;
  const AppointmentDetails({super.key, required this.appointment});

  String formatDate(DateTime date) {
    return DateFormat('MMMd h:mma').format(date);
  }

  String getStartEndTimeString(DateTime start, DateTime end) {
    if (start.isAtSameMomentAs(end)) {
      return formatDate(start);
    } else {
      return '${formatDate(start)} - ${formatDate(end)}';
    }
  }

  bool isExtensionAppointment(Appointment appointment) {
    return appointment is AppointmentEx || appointment.id is! int;
  }

  Future<(WorkSpaceData?, FolderData?, Task?, Task)?> findAssociateTasks(
      int meetingId) async {
    final task = await Get.find<TaskController>()
        .findTaskByDueDateMeeting(appointment.id as int);
    if (task == null) {
      return null;
    }
    final mainTask = await Get.find<TaskController>().getMainTask(task);
    final workSpace = await Get.find<WorkSpaceController>()
        .findFolderByTaskId(mainTask?.id ?? task.id);
    return (workSpace?.item1, workSpace?.item2, mainTask, task);
  }

  @override
  Widget build(BuildContext context) {
    return FlyoutContent(
      shadowColor: material.Colors.transparent,
      padding: EdgeInsets.zero,
      child: Container(
        width: 330,
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isExtensionAppointment(appointment))
                    material.IconButton(
                      color: const Color(0xff92929D),
                      icon: const Icon(material.Icons.edit),
                      splashRadius: 20,
                      iconSize: 16,
                      onPressed: () async {
                        controller.CalendarController calendarController =
                            Get.find();
                        final meeting = await calendarController
                            .findMeetings([appointment.id as int]);

                        // ignore: use_build_context_synchronously
                        await editAppointmentDialog(context,
                            meeting: meeting![0]);
                        Navigator.pop(context);
                      },
                    ),
                  if (!isExtensionAppointment(appointment))
                    material.IconButton(
                      icon: const Icon(material.Icons.delete),
                      splashRadius: 20,
                      iconSize: 16,
                      color: const Color(0xff92929D),
                      onPressed: () async {
                        if (1 ==
                            // ignore: use_build_context_synchronously
                            await showSelectedDialog(context, '提示', '是否删除?')) {
                          controller.CalendarController calendarController =
                              Get.find();
                          await calendarController
                              .deleteMeeting(appointment.id as int);
                        }
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      },
                    ),
                  material.IconButton(
                    icon: const Icon(material.Icons.close),
                    splashRadius: 20,
                    iconSize: 16,
                    color: const Color(0xff92929D),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            Align(
              alignment: Alignment.topLeft,
              child: SelectableText(
                appointment.subject,
                textAlign: TextAlign.left,
                style: FluentTheme.of(context).typography.subtitle,
              ),
            ).marginOnly(left: 20),
            if (!isExtensionAppointment(appointment))
              Align(
                alignment: Alignment.topLeft,
                child: FutureBuilder(
                    future: findAssociateTasks(appointment.id as int),
                    builder: (_, task) {
                      if (task.data == null) return const SizedBox();
                      List<(String, int)> items = [];
                      if (task.data!.$1 != null) {
                        items.add((task.data!.$1!.title, 1));
                      }

                      if (task.data!.$2 != null) {
                        items.add((task.data!.$2!.title, 2));
                      }

                      if (task.data!.$3 != null) {
                        items.add((task.data!.$3!.title, 3));
                      }

                      items.add((task.data!.$4.title, 4));

                      return breadcrumb_bar.BreadcrumbBar<int>(
                        items: items
                            .asMap()
                            .entries
                            .map((e) => breadcrumb_bar.BreadcrumbItem(
                                label: Builder(builder: (context) {
                                  final theme = FluentTheme.of(context);
                                  Widget? iconData;
                                  switch (e.value.$2) {
                                    case 1:
                                      iconData = const Icon(
                                        material.Icons.work_outline,
                                        size: 10,
                                      );

                                      break;
                                    case 2:
                                      iconData = const Icon(
                                        material.Icons.folder_open_outlined,
                                        size: 10,
                                      );

                                      break;
                                    case 3:
                                      iconData = const Icon(
                                        FluentIcons.task_list,
                                        size: 10,
                                      );
                                      break;
                                    case 4:
                                      iconData = Image.asset(
                                        'images/subtask.png',
                                        width: 10,
                                        height: 10,
                                        color: theme.iconTheme.color,
                                      );
                                      break;
                                  }

                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      iconData!.marginOnly(right: 4),
                                      Text(
                                        e.value.$1,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  );
                                }),
                                value: e.value.$2))
                            .toList(),
                        onItemPressed: (item) async {
                          switch (item.value) {
                            case 1:
                              locateFolder(workspace: task.data!.$1!.title);
                              Navigator.of(context).pop();
                              break;
                            case 2:
                              locateFolder(
                                  workspace: task.data!.$1!.title,
                                  folder: task.data!.$2!.title);
                              Navigator.of(context).pop();
                              break;
                            case 3:
                              await showTaskEditDialog(context, task.data!.$3!);
                              break;
                            case 4:
                              await showTaskEditDialog(context, task.data!.$4);
                              break;
                          }
                        },
                      );
                    }),
              ).marginOnly(left: 20),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                  !appointment.isAllDay
                      ? getStartEndTimeString(
                          appointment.startTime, appointment.endTime)
                      : '全天',
                  textAlign: TextAlign.left,
                  style: FluentTheme.of(context).typography.caption!.copyWith(
                      color: FluentTheme.of(context)
                          .typography
                          .caption!
                          .color!
                          .withAlpha(140))),
            ).marginOnly(left: 20),
            if (appointment.notes != null && appointment.notes!.isNotEmpty)
              Align(
                alignment: Alignment.topLeft,
                child: SelectableText(appointment.notes!,
                    textAlign: TextAlign.left,
                    style: FluentTheme.of(context).typography.caption!.copyWith(
                        color: FluentTheme.of(context)
                            .typography
                            .caption!
                            .color!
                            .withAlpha(210))),
              ).marginOnly(left: 20, top: 10),
          ],
        ),
      ),
    );
  }
}
