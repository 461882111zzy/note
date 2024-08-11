import 'package:dailyflowy/app/controllers/calendar_controller.dart';
import 'package:dailyflowy/app/controllers/task_controller.dart';
import 'package:dailyflowy/app/controllers/workspace_controller.dart';
import 'package:dailyflowy/app/data/workspace.dart';
import 'package:dailyflowy/app/routes/utils.dart';
import 'package:dailyflowy/app/views/folder_card.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:dailyflowy/app/controllers/assets_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FolderOverViewWidget extends StatefulWidget {
  final WorkSpaceData? workSpaceData;
  const FolderOverViewWidget({super.key, this.workSpaceData});

  @override
  State<FolderOverViewWidget> createState() => _FolderOverViewWidgetState();
}

class _FolderOverViewWidgetState extends State<FolderOverViewWidget> {
  final AssetsController assetsController = Get.find();
  final WorkSpaceController workSpaceController = Get.find();
  final TaskController taskController = Get.find();
  final CalendarController calendarController = Get.find();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  void fetchData() async {
    final res = widget.workSpaceData?.dirs?.map((val) async {});

    if (res != null) {
      await Future.wait(res.toList());
    }

    _scrollController.jumpTo(0);
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant FolderOverViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.workSpaceData != widget.workSpaceData ||
        oldWidget.workSpaceData?.id != widget.workSpaceData?.id ||
        oldWidget.workSpaceData?.updateTime !=
            widget.workSpaceData?.updateTime) {
      fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.workSpaceData == null || widget.workSpaceData?.dirs == null) {
      return Container();
    }

    final theme = FluentTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.work_outline,
              size: 16,
              color: theme.accentColor,
            ).marginOnly(right: 10),
            Text(
              widget.workSpaceData!.title,
              style: theme.typography.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.accentColor,
                  fontSize: 18.px),
            ),
          ],
        ).marginOnly(bottom: 0, top: 10, left: 10),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(right: 10),
          child: Wrap(
            children: widget.workSpaceData!.dirs!.map((e) {
              return FolderCard(
                title: e.title,
                subTitle:
                    '任务数: ${(e.tasks ?? []).length} 网址数: ${(e.assets ?? []).length}',
                desc:
                    '创建时间: ${DateFormat.yMMMd('zh_CN').format(DateTime.fromMillisecondsSinceEpoch(e.createTime!))}',
                onClick: () {
                  locateFolder(
                      workspace: widget.workSpaceData!.title, folder: e.title);
                },
              ).marginAll(5);
            }).toList(),
          ).marginAll(10),
        )
      ],
    );
  }
}
