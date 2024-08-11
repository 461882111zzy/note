import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:dailyflowy/app/controllers/task_controller.dart';
import 'package:dailyflowy/app/controllers/workspace_controller.dart';
import 'package:dailyflowy/app/data/task.dart';
import 'package:dailyflowy/app/data/workspace.dart';
import 'package:dailyflowy/app/views/note/editor.dart';
import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../tree_drop_down_button.dart';

Future<Task?> showTaskCreateDialog(BuildContext context,
    {FolderData? initFolder}) async {
  return await fluent.showDialog<Task>(
      context: context,
      dismissWithEsc: false,
      barrierColor: Colors.black12,
      builder: (context) {
        return _TaskCreateDialog(initFolder);
      });
}

class _TaskCreateDialog extends StatefulWidget {
  final FolderData? initFolder;
  const _TaskCreateDialog(this.initFolder);

  @override
  State<_TaskCreateDialog> createState() => __TaskCreateDialogState();
}

class __TaskCreateDialogState extends State<_TaskCreateDialog> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _editFocus = FocusNode();

  final EditorState _editorState = EditorState.blank();

  int _subTaskEditting = -1;
  final TextEditingController _subTextEditingController =
      TextEditingController();
  final List<String> _subTasks = [];
  final FocusNode _subTaskfocusNode = FocusNode();
  final FocusScopeNode _scopeNode = FocusScopeNode();
  FolderData? _selectedFolder;

  @override
  void initState() {
    super.initState();
    _subTaskfocusNode.addListener(() {
      if (_subTaskfocusNode.hasFocus == false) {
        setState(() {
          onSubTaskEdit(_subTaskEditting);
        });
      }
    });

    _selectedFolder = widget.initFolder;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Dialog(
        //   alignment: Alignment.bottomRight,
        child: fluent.FlyoutContent(
          child: Localizations.override(
            context: context,
            locale: const Locale('zh-CN'),
            child: Container(
              width: 662.px,
              height: 651.px,
              margin: EdgeInsets.only(
                  left: 50.px, right: 50.px, top: 30.px, bottom: 30.px),
              child: FocusScope(
                node: _scopeNode,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: fluent.TextBox(
                            scrollPadding: EdgeInsets.zero,
                            controller: _textEditingController,
                            onEditingComplete: () {
                              _scopeNode.nextFocus();
                            },
                            style: TextStyle(fontSize: 20.px),
                            maxLength: 40,
                            cursorWidth: 1,
                            placeholderStyle: TextStyle(fontSize: 20.px),
                            padding: const EdgeInsets.all(14),
                            placeholder: '请输入任务名称',
                          ).marginOnly(bottom: 15),
                        )
                      ],
                    ),
                    SizedBox(
                      child: FocusScope(
                        canRequestFocus: false,
                        child: TreeDropDownButton(
                            onSelected: (data) {
                              _selectedFolder = data;
                            },
                            selectedFolder: _selectedFolder),
                      ),
                    ),
                    Container(
                      height: 220.px,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.px),
                        border: Border.all(color: const Color(0x3F7F87A0)),
                      ),
                      margin: const EdgeInsets.only(left: 0, right: 0, top: 15),
                      padding: const EdgeInsets.all(5),
                      child: AppFlowyEditorWidget(
                        focusNode: _editFocus,
                        editorState: _editorState,
                      ),
                    ),
                    Expanded(child: _buildSubTasks().marginOnly(bottom: 10)),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 120.px,
                            child: MouseRegionBuilder(builder: (context, _) {
                              return fluent.Button(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  '取消',
                                ),
                              );
                            }),
                          ),
                          const SizedBox(
                            width: 14,
                          ),
                          SizedBox(
                            width: 120.px,
                            child: MouseRegionBuilder(builder: (context, _) {
                              return fluent.FilledButton(
                                onPressed: () {
                                  _onCreateTask();
                                },
                                child: const Text(
                                  '确定',
                                ),
                              );
                            }),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).marginAll(4),
          ),
        ),
      ),
    );
  }

  Widget _buildSubTasks() {
    final theme = fluent.FluentTheme.of(context);

    final items = <Widget>[];
    if (_subTasks.isNotEmpty) {
      items.add(Text(
        '子任务',
        style: TextStyle(fontSize: 28.px),
      ).marginOnly(bottom: 5, top: 10));
      items.add(Container(
        height: 0.5,
        color: const Color(0xFFD8DBE6),
      ).marginSymmetric(vertical: 15.px));
    }

    final listItems = <Widget>[];

    for (int element = 0; element < _subTasks.length; element++) {
      // editting
      if (element == _subTaskEditting) {
        _subTextEditingController.text = _subTasks[element];
        listItems.add(Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Icon(
              Icons.circle,
              size: 7,
              color: Colors.grey,
            ).marginOnly(right: 10, left: 3.px),
            Expanded(
                flex: 10,
                child: CupertinoTextField.borderless(
                  cursorWidth: 1,
                  scribbleEnabled: false,
                  scrollPadding: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  style: theme.typography.caption,
                  focusNode: _subTaskfocusNode,
                  onEditingComplete: () {
                    setState(() {
                      onSubTaskEdit(element);
                    });
                  },
                  controller: _subTextEditingController,
                )),
            const Spacer(
              flex: 1,
            ),
            const Icon(
              Icons.delete_outline,
              size: 16,
            ),
          ],
        ).marginOnly(bottom: 5, left: 0, right: 10));
      } else {
        listItems.add(Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Icon(
              Icons.circle,
              size: 7,
              color: Colors.grey,
            ).marginOnly(right: 10, left: 3),
            Text(_subTasks[element], style: theme.typography.caption),
            const Spacer(),
            GestureDetector(
              onTap: () {
                setState(() {
                  _subTaskEditting = element;
                  _subTaskfocusNode.requestFocus();
                });
              },
              child: const Icon(
                Icons.edit,
                size: 16,
              ).marginOnly(right: 7),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _subTasks.removeAt(element);
                });
              },
              child: const Icon(
                Icons.delete_outline,
                size: 16,
              ).marginOnly(right: 7),
            ),
          ],
        ).marginOnly(bottom: 5, left: 0, right: 10));
      }
    }

    items.add(Expanded(
        child: ListView(
      children: listItems,
    )));

    listItems.add(
      Row(
        children: [
          MouseRegionBuilder(builder: (context, _) {
            return CupertinoButton(
              padding: EdgeInsets.zero,
              child: Row(
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
              onPressed: () {
                if (_subTaskEditting != -1) {
                  return;
                }
                _subTasks.add('');
                setState(() {
                  _subTaskEditting = _subTasks.length - 1;
                });
                _subTaskfocusNode.requestFocus();
              },
            ).marginOnly(left: 0, top: 5);
          })
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    ).marginOnly(top: 10, left: 0, right: 25);
  }

  void onSubTaskEdit(int element) {
    _subTaskEditting = -1;
    _subTasks[element] = _subTextEditingController.text;
    if (_subTextEditingController.text.trim().isEmpty) {
      _subTasks.removeAt(element);
    }
  }

  Future<void> _onCreateTask() async {
    if (_textEditingController.text.isEmpty) {
      showToast(context, '提示', '请输入任务名称');
      return;
    }

    if (_selectedFolder == null) {
      showToast(context, '提示', '请选择目录');
      return;
    }

    Navigator.of(context).pop();

    final taskController = Get.find<TaskController>();

    Stream<Task> createSubtask() async* {
      for (var element in _subTasks) {
        final task = Task()
          ..title = element
          ..priority = Priority.low
          ..taskStatus = TaskStatus.unstart
          ..createTime = DateTime.now().millisecondsSinceEpoch;
        task.id = await taskController.addTask(task);
        yield task;
      }
    }

    final List<Task> subTasks = [];
    await for (Task task in createSubtask()) {
      subTasks.add(task);
    }

    final task = Task()
      ..title = _textEditingController.text
      ..desc = jsonEncode(_editorState.document.toJson())
      ..priority = Priority.low
      ..taskStatus = TaskStatus.unstart
      ..subTasks = subTasks.map<int>((e) => e.id).toList()
      ..createTime = DateTime.now().millisecondsSinceEpoch;

    // 重新去数据库拿folder
    final lastFolder = await Get.find<WorkSpaceController>()
        .findFolder(_selectedFolder!.title, _selectedFolder!.parentId);

    int id = await taskController.addTask(task);
    List<int> tasks = [];
    tasks.addAll(lastFolder?.tasks ?? []);
    tasks.add(id);
    lastFolder?.tasks = tasks;

    await Get.find<WorkSpaceController>().updateFolder(lastFolder!);
  }
}
