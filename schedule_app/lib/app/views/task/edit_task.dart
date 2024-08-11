import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:dailyflowy/app/controllers/message_controller.dart';
import 'package:dailyflowy/app/controllers/task_controller.dart';
import 'package:dailyflowy/app/controllers/utils.dart';
import 'package:dailyflowy/app/controllers/workspace_controller.dart';
import 'package:dailyflowy/app/data/meeting.dart';
import 'package:dailyflowy/app/data/message.dart';
import 'package:dailyflowy/app/data/task.dart';
import 'package:dailyflowy/app/data/workspace.dart';
import 'package:dailyflowy/app/modules/2_taskboard/views/show_add_text_dialog.dart';
import 'package:dailyflowy/app/routes/url_route.dart';
import 'package:dailyflowy/app/views/note/editor.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:dailyflowy/app/views/widgets/breadcrumb_bar.dart';
import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:dailyflowy/app/views/priority_popup.dart';
import 'package:dailyflowy/app/views/tree_drop_down_button.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tiny_logger/tiny_logger.dart';

import '../../controllers/calendar_controller.dart';
import '../colors_util.dart';
import '../due_date_widget.dart';

Future<bool?> showTaskEditDialog(BuildContext context, Task task) async {
  return await fluent.showDialog<bool>(
      context: context,
      dismissWithEsc: false,
      barrierColor: Colors.black12,
      builder: (context) {
        return _TaskEditDialog(task: task);
      });
}

class _TaskEditDialog extends StatefulWidget {
  final Task task;

  const _TaskEditDialog({required this.task}) : super();
  @override
  _State createState() => _State();
}

class _State extends State<_TaskEditDialog> {
  late TextEditingController _title;
  late TextEditingController _msgInput;
  late ScrollController _msgController;
  late EditorState _editorState;
  final FocusNode _editFocus = FocusNode();
  late TaskStatus _taskStatus;
  late bool _hasSubTask;
  late Task _task;
  Task? _mainTask;
  bool _isCurrentMainTask = false;
  List<Task>? _subTask;
  GlobalKey _key = GlobalKey();
  Meeting? _meeting;
  WorkSpaceData? _workSpaceData;
  FolderData? _folderData;
  late List<Message> _messages = [];
  final _subtaskListviewController = ScrollController();

  @override
  void initState() {
    _task = widget.task;
    _taskStatus = _task.taskStatus;

    _title = TextEditingController();
    _title.text = _task.title;

    _msgInput = TextEditingController();
    _msgController = ScrollController();

    _initEditorState(_task.desc);

    super.initState();

    _hasSubTask = _task.subTasks != null && _task.subTasks!.isNotEmpty;
    if (_hasSubTask) {
      _fetchSubTask();
    }

    _fetchMainTask();
    _fetchMessages();
    _fetchMeeting();

    _isMainTask(_task).then((value) {
      _isCurrentMainTask = value;
    });
  }

  void _initEditorState(String? text) {
    Document doc = Document.blank(withInitialText: true);
    if (text != null && text != '') {
      dynamic data = jsonDecode(_task.desc!);
      try {
        doc = Document.fromJson(data);
      } catch (e) {
        try {
          doc = quillDeltaEncoder.convert(Delta.fromJson(data));
        } catch (e) {
          //保护逻辑，避免数据被冲掉
          log.error(e);
          Navigator.pop(context);
        }
      }
    }

    _editorState = EditorState(document: doc);
  }

  static const formatStr = "yyyy-MM-dd hh:mm a";
  static final formatter = DateFormat(formatStr, 'zh_CN');
  static String millionsTimeToStr(int millionsTime) {
    return formatter.format(DateTime.fromMillisecondsSinceEpoch(millionsTime));
  }

  Future<void> save() async {
    if (_title.text == '') {
      return;
    }

    final desc = jsonEncode(_editorState.document.toJson());

    if (_task.title == _title.text &&
        desc == _task.desc &&
        _task.messages?.length == _messages.length &&
        _taskStatus == _task.taskStatus) {
      return;
    }

    _task.title = _title.text;
    _task.taskStatus = _taskStatus;
    _task.desc = desc;
    _task.updateTime = DateTime.now().millisecondsSinceEpoch;
    _task.messages = _messages.map((e) => e.id).toList();

    final taskController = Get.find<TaskController>();
    await taskController.updateTask(_task);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) async {
        save();
      },
      child: Dialog(
        child: fluent.FlyoutContent(
          child: SizedBox(
            width: 800,
            height: 600,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: CloseButton(
                    onPressed: () {
                      save();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                      top: 5, left: 20, right: 20, bottom: 20),
                  child: Row(mainAxisSize: MainAxisSize.max, children: [
                    Flexible(flex: 2, child: _buildLeftZone(context)),
                    Container(
                        width: 1,
                        margin: const EdgeInsets.only(top: 40),
                        height: double.infinity,
                        color: Colors.grey.withAlpha(100)),
                    Expanded(
                      child: _buildMessageZone().marginOnly(top: 20),
                    )
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftZone(BuildContext context) {
    final theme = fluent.FluentTheme.of(context);
    return Container(
      height: double.infinity,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: _buildFolderPath(),
          ).marginOnly(left: 0, top: 8, bottom: 8),
          _buildPropModifyZone(),
          SizedBox(
            height: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_mainTask != null)
                  Image.asset(
                    'images/subtask.png',
                    width: 16,
                    height: 16,
                    color: theme.typography.subtitle!.color,
                  ).marginOnly(right: 5),
                Expanded(child: _buildTitleEditor()),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withAlpha(100),
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(4),
              child: AppFlowyEditorWidget(
                editorState: _editorState,
                focusNode: _editFocus,
              ),
            ),
          ),
          _buildSubTaskList()
        ],
      ),
    );
  }

  Widget _buildFolderPath() {
    if (_workSpaceData != null && _folderData != null) {
      const style = TextStyle(fontSize: 10, height: 0.8);
      final items = [
        BreadcrumbItem(
            label: Row(
              mainAxisSize: fluent.MainAxisSize.min,
              crossAxisAlignment: fluent.CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.work_outline,
                  size: 10,
                ).marginOnly(right: 4),
                Text(_workSpaceData!.title, style: style),
              ],
            ),
            value: 0),
        BreadcrumbItem(
            label: Row(
              mainAxisSize: fluent.MainAxisSize.min,
              crossAxisAlignment: fluent.CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.folder_open_outlined,
                  size: 10,
                ).marginOnly(right: 4),
                Text(
                  _folderData!.title,
                  style: style,
                ),
              ],
            ),
            value: 1),
      ];

      if (_mainTask != null) {
        items.add(BreadcrumbItem(
            label: fluent.Row(
              crossAxisAlignment: fluent.CrossAxisAlignment.center,
              mainAxisSize: fluent.MainAxisSize.min,
              children: [
                const Icon(
                  fluent.FluentIcons.task_list,
                  size: 10,
                ).marginOnly(right: 4),
                Text(_mainTask!.title, style: style),
              ],
            ),
            value: 2));
      }

      return BreadcrumbBar(
          items: items,
          onItemPressed: (value) {
            if (value.value == 0) {
              uriRoute.shell(Uri(path: 'p', queryParameters: {
                'workspace': _workSpaceData!.title,
              }));
              Navigator.pop(context);
            } else if (value.value == 1) {
              uriRoute.shell(Uri(path: 'p', queryParameters: {
                'workspace': _workSpaceData!.title,
                'folder': _folderData!.title
              }));
              Navigator.pop(context);
            } else if (value.value == 2) {
              _backToMainTask();
            }
          });
    } else {
      return SizedBox(
        width: 200,
        child: TreeDropDownButton(onSelected: (FolderData folderData) {
          onSelectFolderForFix(folderData);
        }),
      );
    }
  }

  Widget _buildMessageZone() {
    final theme = fluent.FluentTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text(
          '时间跟踪',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Expanded(
            child: ListView.builder(
          reverse: true,
          controller: _msgController,
          itemBuilder: (context, index) {
            final item = _messages[_messages.length - index - 1];
            return SelectionArea(
              child: Container(
                margin: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        millionsTimeToStr(item.time),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: theme.acrylicBackgroundColor,
                            boxShadow: [
                              BoxShadow(
                                  spreadRadius: 3,
                                  color: Colors.grey.withAlpha(10))
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          item.msg,
                          style: const TextStyle(fontSize: 14),
                        ))
                  ],
                ),
              ),
            );
          },
          itemCount: _messages.length,
        )),
        Container(
          width: double.infinity,
          height: 1,
          margin: const EdgeInsets.only(left: 8),
          color: Colors.grey.withAlpha(100),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 5, bottom: 8.0),
          child: fluent.TextBox(
            controller: _msgInput,
            style: TextStyle(
                color: theme.typography.subtitle!.color, fontSize: 14.0),
            minLines: 2,
            maxLines: 5,
            showCursor: true,
            textAlignVertical: TextAlignVertical.top,
            cursorWidth: 1,
            textAlign: TextAlign.left,
            cursorColor: theme.accentColor,
            placeholder: '添加跟踪',
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: fluent.SizedBox(
            width: 80,
            child: fluent.FilledButton(
              onPressed: () {
                _onAddMessage();
              },
              child: const Text('添加'),
            ),
          ),
        )
      ],
    );
  }

  void _onAddMessage() {
    if (_msgInput.text.trim().isEmpty) {
      _msgInput.clear();
      return;
    }
    final message = Message()
      ..time = DateTime.now().millisecondsSinceEpoch
      ..msg = _msgInput.text;
    final messageController = Get.find<MessageController>();
    messageController.addMessage(message);
    _messages.add(message);

    setState(() {});
    _msgInput.clear();
    _msgController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.bounceIn);
  }

  Widget _buildTitleEditor() {
    final theme = fluent.FluentTheme.of(context);
    return CupertinoTextField(
      controller: _title,
      padding: const EdgeInsets.all(3),
      style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: theme.typography.subtitle!.color),
      minLines: 1,
      maxLines: 1,
      showCursor: true,
      textAlignVertical: TextAlignVertical.top,
      cursorWidth: 1,
      textAlign: TextAlign.left,
      cursorColor: theme.accentColor,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide.none,
        ),
      ),
      placeholder: '输入计划',
      placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey),
    );
  }

  void _fetchMessages() async {
    final messageController = Get.find<MessageController>();
    _messages = await messageController.findMessages(_task.messages) ?? [];
    setState(() {});
  }

  Future<void> _fetchSubTask() async {
    final taskController = Get.find<TaskController>();
    final task = await taskController.getSubTasks(_task);
    setState(() {
      _subTask = task;
    });
  }

  void _fetchMainTask() async {
    final taskController = Get.find<TaskController>();
    _mainTask = await taskController.getMainTask(_task);
    await _fetchWorkspace();
  }

  Future<bool> _isMainTask(Task task) async {
    final taskController = Get.find<TaskController>();
    final res = await taskController.getMainTask(task);
    return res == null;
  }

  Future<void> _fetchWorkspace() async {
    final rootTask = _mainTask ?? _task;
    final workSpace = Get.find<WorkSpaceController>();
    final res = await workSpace.findFolderByTaskId(rootTask.id);
    if (res != null) {
      setState(() {
        _workSpaceData = res.item1;
        _folderData = res.item2;
      });
    }
  }

  void _backToMainTask() {
    if (_mainTask == null) return;
    final target = _mainTask;
    _mainTask = null;
    _switchTask(target!);
  }

  void _gotoSubTask(Task task) {
    _switchTask(task);
  }

  void _switchTask(Task task) async {
    await save();

    _task = task;
    _meeting = null;
    _messages = [];
    _subTask = [];
    _key = GlobalKey();

    _title.text = _task.title;
    _initEditorState(_task.desc);
    _taskStatus = _task.taskStatus;
    _hasSubTask = _task.subTasks != null && _task.subTasks!.isNotEmpty;
    if (_hasSubTask) {
      _fetchSubTask();
    }
    _fetchMainTask();
    _fetchMessages();
    _fetchMeeting();

    _isCurrentMainTask = await _isMainTask(_task);

    setState(() {});
  }

  Widget _buildPropModifyZone() {
    final theme = fluent.FluentTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.scale(
          scale: 0.7,
          child: Checkbox(
              tristate: true,
              activeColor: theme.accentColor,
              value: _taskStatus == TaskStatus.done,
              onChanged: (_) {
                setState(() {
                  if (_taskStatus == TaskStatus.done) {
                    _taskStatus = TaskStatus.processing;
                  } else {
                    _taskStatus = TaskStatus.done;
                  }
                });
              }),
        ),
        const SizedBox(
          width: 8,
        ),
        PriorityPopupButton(
          onSelected: (data) {
            setState(() {
              _task.priority = data;
            });

            Get.find<TaskController>()
                .updateTask(_task, isNotifyRefresh: false);
          },
          initialValue: _task.priority,
          child: Icon(
            Icons.flag,
            size: 14,
            color: getPriorityColor(_task.priority),
          ),
        ),
        const SizedBox(
          width: 15,
        ),
        DueDateWidget(
          due: _meeting,
          task: _task,
          onDueChanged: (val) {
            setState(() {
              _meeting = val;
            });
          },
        ),
      ],
    );
  }

  void _fetchMeeting() async {
    if (_task.dueDateMeetingId == null) return;
    final calendarController = Get.find<CalendarController>();
    final meeting =
        await calendarController.findMeetings([_task.dueDateMeetingId]);
    meeting?.forEach((val) {
      setState(() {
        _meeting = val;
      });
    });
  }

  Widget _buildSubTaskList() {
    final theme = fluent.FluentTheme.of(context);
    if (!_isCurrentMainTask) return Container();
    return Container(
      //  height: 200,
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_subTask != null && _subTask!.isNotEmpty)
            const Text(
              '子任务',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          if (_subTask != null && _subTask!.isNotEmpty)
            if (_subTask!.length < 5)
              ..._subTask!.map((item) {
                return _buildSubTaskItem(item, theme);
              }),
          if (_subTask != null && _subTask!.length > 4)
            SizedBox(
              height: 150,
              child: ListView.builder(
                controller: _subtaskListviewController,
                itemBuilder: (context, index) {
                  return _buildSubTaskItem(_subTask![index], theme);
                },
                itemCount: _subTask!.length,
              ),
            ),
          MouseRegionBuilder(builder: (context, _) {
            return CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 20,
              child: Row(
                mainAxisSize: fluent.MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 20.0.px,
                    color: theme.accentColor,
                  ),
                  Text(
                    '子任务',
                    style: TextStyle(fontSize: 13, color: theme.accentColor),
                  ),
                ],
              ),
              onPressed: () async {
                final text = await showAddTextDialog(context);
                if (text == null || text.isEmpty) {
                  return;
                }
                await addSubTask(text, _task);
                await _fetchSubTask();
                await Future.delayed(const Duration(milliseconds: 100));
                _subtaskListviewController.jumpTo(
                    _subtaskListviewController.position.maxScrollExtent);
              },
            );
          })
        ],
      ),
    );
  }

  GestureDetector _buildSubTaskItem(Task item, fluent.FluentThemeData theme) {
    return GestureDetector(
      onTap: () {
        _gotoSubTask(item);
      },
      child: MouseRegionBuilder(builder: (context, enterd) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'images/subtask.png',
              width: 10,
              height: 10,
              color: theme.typography.subtitle!.color,
            ),
            Container(
                padding: const EdgeInsets.all(5),
                child: Text(
                  item.title,
                  style: TextStyle(
                      fontSize: 14,
                      decoration: enterd
                          ? TextDecoration.underline
                          : TextDecoration.none),
                ))
          ],
        );
      }),
    );
  }

  void onSelectFolderForFix(FolderData folderData) async {
    _folderData = await Get.find<WorkSpaceController>()
        .findFolder(folderData.title, folderData.parentId);

    _workSpaceData = await Get.find<WorkSpaceController>()
        .findWorkspace(_folderData!.parentId);

    final rootTask = _mainTask ?? _task;
    final tasks = <int>[...?_folderData?.tasks];
    tasks.add(rootTask.id);
    _folderData!.tasks = tasks;

    Get.find<WorkSpaceController>().updateFolder(_folderData!);
    setState(() {});
  }
}
