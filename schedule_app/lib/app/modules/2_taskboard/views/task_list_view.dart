import 'package:dailyflowy/app/controllers/calendar_controller.dart';
import 'package:dailyflowy/app/controllers/task_controller.dart';
import 'package:dailyflowy/app/controllers/utils.dart';
import 'package:dailyflowy/app/data/meeting.dart';
import 'package:dailyflowy/app/data/task.dart';
import 'package:dailyflowy/app/data/utils.dart';
import 'package:dailyflowy/app/data/workspace.dart';
import 'package:dailyflowy/app/modules/2_taskboard/views/show_add_text_dialog.dart';
import 'package:dailyflowy/app/views/colors_util.dart';
import 'package:dailyflowy/app/views/task/create_task.dart';
import 'package:dailyflowy/app/views/task/edit_task.dart';
import 'package:dailyflowy/app/views/widgets/expansion.dart';
import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:dailyflowy/app/views/priority_popup.dart';
import 'package:dailyflowy/app/views/widgets/selected_dialog.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:fluent_ui/fluent_ui.dart' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskListView extends StatefulWidget {
  final FolderData? folderData;
  final int timestamp;
  const TaskListView(
      {super.key, required this.folderData, required this.timestamp});

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView>
    with AutomaticKeepAliveClientMixin {
  List<Task>? _showTasks;
  Map<int, Task>? _subTasks;
  Map<int, Meeting>? _meeting;
  @override
  bool get wantKeepAlive => true;

  bool _showComplete = false;
  final String kIsShowCompleteTask = 'showCompleteTask';

  @override
  void initState() {
    super.initState();
    _loadShowCompletedTask();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        const ui.Divider(
          direction: Axis.horizontal,
          style: ui.DividerThemeData(
              verticalMargin: EdgeInsets.zero,
              horizontalMargin: EdgeInsets.zero),
        ),
        _buildOperationArea(context).marginOnly(top: 5, left: 10, bottom: 5),
        Expanded(child: _buildTaskList(context)),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _onShowFolder(widget.folderData);
  }

  @override
  void didUpdateWidget(covariant TaskListView oldWidget) {
    if (oldWidget.folderData != widget.folderData ||
        oldWidget.timestamp != widget.timestamp) {
      _onShowFolder(widget.folderData);
    }

    super.didUpdateWidget(oldWidget);
  }

  void _onShowFolder(FolderData? data) async {
    if (data == null) {
      return;
    }
    final showTasks = await Get.find<TaskController>().findTasks(data.tasks);
    _sortTaskList(showTasks);
    setState(() {
      _showTasks = showTasks;
      _subTasks = null;
    });

    if (showTasks == null || showTasks.isEmpty) {
      return;
    }
    _meeting = {};
    fetchMeeting(showTasks);

    List<int>? subTaskId = [];
    Map<int, Task> subTasks = {};

    for (int i = 0; i < showTasks.length; i++) {
      subTaskId.addAll(showTasks[i].subTasks!);
    }

    const steps = 20;
    while (subTaskId!.isNotEmpty) {
      List<int> ids = [];
      final takes = subTaskId.take(steps);
      subTaskId = subTaskId.skip(takes.length).toList();
      ids.addAll(takes);
      final resSubTasks = await Get.find<TaskController>().findTasks(ids);

      if (showTasks != _showTasks) {
        break;
      }

      if (resSubTasks != null) {
        for (var element in resSubTasks) {
          subTasks.putIfAbsent(element.id, () => element);
        }
      }

      setState(() {
        _subTasks = subTasks;
      });
    }

    if (_subTasks != null) {
      fetchMeeting(_subTasks!.values.toList());
    }
  }

  Future<void> fetchMeeting(List<Task> showTasks) async {
    List<int> duaDataMeetingIDs = [];
    for (var element in showTasks) {
      if (element.dueDateMeetingId != null) {
        duaDataMeetingIDs.add(element.dueDateMeetingId!);
      }
    }
    final calendarController = Get.find<CalendarController>();
    final meeting = await calendarController.findMeetings(duaDataMeetingIDs);
    meeting?.forEach((val) {
      _meeting?[val.id] = val;
    });

    setState(() {});
  }

  Widget _buildTaskList(BuildContext context) {
    final sortValuesCount =
        _showTasks != null ? calcSortValueItemCounts(_showTasks!) : null;

    var renderTasks = _showTasks;
    if (!_showComplete && _showTasks != null) {
      renderTasks = [];
      for (var element in _showTasks!) {
        if (element.taskStatus != TaskStatus.done) {
          renderTasks.add(element);
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: (widget.folderData != null &&
              renderTasks != null &&
              renderTasks.isNotEmpty)
          ? ListView.builder(
              itemBuilder: (context, index) {
                final task = renderTasks![index];
                List<Widget> childs = [];
                if (_subTasks != null && _subTasks!.isNotEmpty) {
                  task.subTasks?.forEach((id) {
                    final sub = _subTasks![id];
                    if (sub != null &&
                        (_showComplete || sub.taskStatus != TaskStatus.done)) {
                      childs.add(_buildTaskItem(
                        sub,
                        Row(
                          children: [
                            if (sub.taskStatus != TaskStatus.done)
                              _buildLineUpButton(sub),
                            CupertinoButton(
                                onPressed: () {
                                  _deleteSubTask(task, sub);
                                },
                                minSize: 16,
                                borderRadius: BorderRadius.circular(2),
                                padding: const EdgeInsets.all(0),
                                child: Icon(
                                  Icons.delete_forever_sharp,
                                  size: 16,
                                  color: Colors.grey.withAlpha(230),
                                )).marginOnly(left: 4, right: 4),
                          ],
                        ),
                      ).paddingOnly(left: 30));
                    }
                  });
                }
                final last = renderTasks.length - 1 == index;
                Widget childItem = _buildTaskItemWrapper(last, task, childs);

                if (_isDifferentSortValueWithLastTask(index)) {
                  childItem = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ui.Divider(
                        style: ui.DividerThemeData(
                            horizontalMargin: EdgeInsets.zero),
                      ).marginOnly(bottom: index != 0 ? 20 : 5),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4)),
                            child: Container(
                                color: getTaskStatusColor(
                                    task.taskStatus, context),
                                padding: const EdgeInsets.only(
                                    left: 5, right: 5, top: 4, bottom: 4),
                                child: Text(
                                  _buildTaskStatusWording(task.taskStatus),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.white),
                                )),
                          ).marginOnly(left: 0),
                          Text(
                            '${sortValuesCount![task.taskStatus.index]} 个任务',
                            style: const TextStyle(fontSize: 9),
                          ).marginOnly(left: 6, top: 3),
                          const Spacer(),
                          const Text(
                            '优先级',
                            style: TextStyle(fontSize: 9),
                          ).marginOnly(right: 37, top: 3),
                          const Text(
                            '到期日',
                            style: TextStyle(fontSize: 9),
                          ).marginOnly(right: 54, top: 3),
                        ],
                      ),
                      Container(
                        height: 12,
                        margin: const EdgeInsets.only(left: 0),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                                width: 0.5, color: Colors.grey.withAlpha(50)),
                            right: BorderSide(
                                width: 0.5, color: Colors.grey.withAlpha(50)),
                            left: BorderSide(
                                width: 0.5, color: Colors.grey.withAlpha(50)),
                          ),
                        ),
                      ),
                      childItem
                    ],
                  );
                }

                return childItem;
              },
              itemCount: renderTasks.length,
            )
          : Image.asset(
              'images/logo_big.png',
              width: 300,
            ),
    );
  }

  Widget _buildLineUpButton(Task task) {
    return CupertinoButton(
        onPressed: () {
          addToLineUp(task);
        },
        color: Colors.grey.withAlpha(100),
        minSize: 16,
        borderRadius: BorderRadius.circular(2),
        padding: const EdgeInsets.all(0),
        child: const Icon(
          Icons.move_up,
          size: 12,
        )).marginOnly(left: 4);
  }

  Container _buildTaskItemWrapper(bool last, Task task, List<Widget> childs) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
            left: BorderSide(width: 0.5, color: Colors.grey.withAlpha(50)),
            right: BorderSide(width: 0.5, color: Colors.grey.withAlpha(50)),
            top: BorderSide.none,
            bottom: last
                ? BorderSide(width: 0.5, color: Colors.grey.withAlpha(50))
                : BorderSide.none),
      ),
      margin: const EdgeInsets.only(left: 0),
      padding: EdgeInsets.only(left: 8, right: 8, bottom: last ? 13 : 8),
      child: Container(
        decoration: BoxDecoration(
            color: ui.FluentTheme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                  blurRadius: 0.5,
                  color: ui.FluentTheme.of(context).shadowColor.withAlpha(100),
                  blurStyle: ui.BlurStyle.outer)
            ],
            borderRadius: const BorderRadius.all(Radius.circular(4.0))),
        margin: const EdgeInsets.only(left: 4, right: 4),
        child: ExpansionWidget(
          shape: const Border(),
          collapsedShape: const Border(),
          header: _buildTaskItem(
              task,
              Row(
                children: [
                  CupertinoButton(
                      onPressed: () {
                        _addSubTask(task);
                      },
                      color: Colors.grey.withAlpha(100),
                      minSize: 16,
                      borderRadius: BorderRadius.circular(2),
                      padding: const EdgeInsets.all(0),
                      child: const Icon(
                        Icons.add,
                        size: 12,
                      )).marginOnly(left: 4, right: 4),
                  maybeTooltip(
                    message: toPlainText(task.desc),
                    child: CupertinoButton(
                        onPressed: () {},
                        color: Colors.grey.withAlpha(100),
                        minSize: 16,
                        borderRadius: BorderRadius.circular(2),
                        padding: const EdgeInsets.all(0),
                        child: const Icon(
                          Icons.short_text_rounded,
                          size: 12,
                        )),
                  ),
                  if (task.taskStatus != TaskStatus.done)
                    _buildLineUpButton(task).marginOnly(left: 4),
                  CupertinoButton(
                      onPressed: () {
                        _deleteTask(task);
                      },
                      minSize: 16,
                      borderRadius: BorderRadius.circular(2),
                      padding: const EdgeInsets.all(0),
                      child: Icon(
                        Icons.delete_forever_sharp,
                        size: 16,
                        color: Colors.grey.withAlpha(230),
                      )).marginOnly(left: 4, right: 4),
                ],
              )),
          initiallyExpanded: true,
          expandedAlignment: Alignment.centerLeft,
          children: childs,
        ),
      ),
    );
  }

  Widget _buildOperationArea(BuildContext context) {
    return ui.CommandBar(
      isCompact: false,
      overflowBehavior: ui.CommandBarOverflowBehavior.noWrap,
      primaryItems: [
        ui.CommandBarButton(
          icon: Icon(
            ui.FluentIcons.filter_solid,
            size: 12,
            color: _showComplete
                ? ui.FluentTheme.of(context).selectionColor
                : ui.FluentTheme.of(context).activeColor,
          ),
          label: Text(
            '已完成',
            style: ui.FluentTheme.of(context)
                .typography
                .body!
                .copyWith(fontSize: 12),
          ),
          onPressed: () {
            setState(() {
              _showComplete = !_showComplete;
              _setShowCompletedTask(_showComplete);
            });
          },
        ),
        ui.CommandBarButton(
          icon: const Icon(
            ui.FluentIcons.add,
            size: 12,
          ),
          label: Text(
            '添加',
            style: ui.FluentTheme.of(context)
                .typography
                .body!
                .copyWith(fontSize: 12),
          ),
          onPressed: () {
            showTaskCreateDialog(context, initFolder: widget.folderData);
          },
        ),
      ],
    );
  }

  Widget _buildTaskItem(Task task, Widget? option) {
    Meeting? due = _meeting![task.dueDateMeetingId];
    return MouseRegionBuilder(builder: (context, entered) {
      return GestureDetector(
        onTap: () {
          showTaskEditDialog(context, task);
        },
        child: SizedBox(
          height: 25,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              MouseRegionBuilder(builder: (context, entered) {
                return GestureDetector(
                  onTap: () {
                    _onClickTaskStatus(task);
                  },
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: entered || task.taskStatus == TaskStatus.done
                        ? ui.FluentTheme.of(context).accentColor
                        : ui.FluentTheme.of(context).typography.title!.color,
                  ),
                );
              }),
              Text(
                task.title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13,
                    color: entered
                        ? ui.FluentTheme.of(context).accentColor
                        : ui.FluentTheme.of(context).typography.title!.color),
              ).marginOnly(left: 7, right: 4),
              task.subTasks != null && task.subTasks!.isNotEmpty
                  ? Container(
                      height: 16,
                      padding: const EdgeInsets.only(left: 3, right: 3),
                      decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(100),
                          borderRadius: BorderRadius.circular(2)),
                      child: Center(
                        child: Text(
                          '${task.subTasks!.length}',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                        ),
                      ),
                    )
                  : const SizedBox(),
              entered ? (option ?? const SizedBox()) : const SizedBox(),
              const Spacer(),
              PriorityPopupButton(
                onSelected: (data) {
                  setState(() {
                    task.priority = data;
                  });

                  Get.find<TaskController>()
                      .updateTask(task, isNotifyRefresh: false);
                },
                initialValue: task.priority,
                child: Icon(
                  Icons.flag,
                  size: 14,
                  color: getPriorityColor(task.priority),
                ),
              ).marginOnly(right: due == null ? 50 : 41),
              MouseRegionBuilder(builder: (context, entered) {
                return GestureDetector(
                  onTap: () async {
                    final date = await showDatePickerEx(
                      context,
                      initDate: due != null ? due.to! : DateTime.now(),
                    );
                    if (date == null) {
                      return;
                    }
                    final meeting = await setTaskDueDate(task, date);
                    setState(() {
                      _meeting?[meeting.id] = meeting;
                    });
                  },
                  child: due != null
                      ? Container(
                          width: 30,
                          height: 14,
                          padding: const EdgeInsets.only(top: 5),
                          child: Center(
                            child: Text(
                              '${due.to!.month}-${due.to!.day}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  height: 0.8,
                                  fontSize: 10,
                                  color:
                                      ui.FluentTheme.of(context).accentColor),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.calendar_today,
                          color: ui.FluentTheme.of(context)
                              .typography
                              .subtitle!
                              .color!
                              .withOpacity(0.5),
                          size: 14,
                        ),
                );
              }).marginOnly(right: due == null ? 50 : 43),
            ],
          ),
        ),
      );
    });
  }

  void _addSubTask(Task task) async {
    final text = await showAddTextDialog(context);
    if (text == null || text.isEmpty) {
      return;
    }
    await addSubTask(text, task);
    setState(() {});
  }

  void _onClickTaskStatus(Task task) {
    if (task.taskStatus == TaskStatus.unstart ||
        task.taskStatus == TaskStatus.processing) {
      task.taskStatus = TaskStatus.done;
      final taskController = Get.find<TaskController>();
      taskController.updateTask(task, isNotifyRefresh: false);
      _sortTaskList(_showTasks);
      setState(() {});
      showToast(context, '提示', '一项任务已完成', severity: ui.InfoBarSeverity.success);
      return;
    }

    if (task.taskStatus == TaskStatus.done) {
      task.taskStatus = TaskStatus.processing;
      final taskController = Get.find<TaskController>();
      taskController.updateTask(task, isNotifyRefresh: false);
      _sortTaskList(_showTasks);
      setState(() {});
      showToast(context, '提示', '一项任务要重新开始', severity: ui.InfoBarSeverity.info);
      return;
    }
  }

  void _sortTaskList(List<Task>? tasks) {
    if (tasks == null) {
      return;
    }
    tasks.sort((left, right) {
      return left.taskStatus.index - right.taskStatus.index;
    });
  }

  Map<int, int> calcSortValueItemCounts(List<Task> tasks) {
    Map<int, int> values = {};

    for (var element in tasks) {
      values[element.taskStatus.index] ??= 0;
      values[element.taskStatus.index] = values[element.taskStatus.index]! + 1;
    }

    return values;
  }

  bool _isDifferentSortValueWithLastTask(int currentIndex) {
    if (currentIndex == 0) {
      return true;
    }

    if (_showTasks == null) {
      return false;
    }

    final current = _showTasks![currentIndex];
    final last = _showTasks![currentIndex - 1];

    return current.taskStatus != last.taskStatus;
  }

  void _deleteTask(Task task) async {
    final res = await showSelectedDialog(context, '提示', '是否删除?');
    if (res != 1) {
      return;
    }

    await deleteTask(task, widget.folderData);
  }

  void _deleteSubTask(Task task, Task sub) async {
    final res = await showSelectedDialog(context, '提示', '是否删除?');
    if (res != 1) {
      return;
    }
    await deleteSubTask(sub, task);
    setState(() {});
  }

  String _buildTaskStatusWording(TaskStatus taskStatus) {
    const wording = ['未开始', '进行中', '已完成', '已删除'];
    return wording[taskStatus.index];
  }

  void _loadShowCompletedTask() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _showComplete = prefs.getBool(kIsShowCompleteTask) ?? true;
    setState(() {});
  }

  void _setShowCompletedTask(bool show) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(kIsShowCompleteTask, show);
  }
}
