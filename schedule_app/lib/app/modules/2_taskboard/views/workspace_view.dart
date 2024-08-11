import 'dart:async';

import 'package:dailyflowy/app/controllers/task_controller.dart';
import 'package:dailyflowy/app/controllers/utils.dart';
import 'package:dailyflowy/app/controllers/workspace_controller.dart';
import 'package:dailyflowy/app/data/base_data.dart';
import 'package:dailyflowy/app/data/workspace.dart';
import 'package:dailyflowy/app/modules/2_taskboard/views/show_add_text_dialog.dart';
import 'package:dailyflowy/app/views/task/create_task.dart';
import 'package:dailyflowy/app/views/widgets/drag_drop_tree_view.dart'
    as tree_view;
import 'package:dailyflowy/app/views/folder_opt_menu.dart';
import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:dailyflowy/app/views/widgets/selected_dialog.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:fluent_ui/fluent_ui.dart' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiny_logger/tiny_logger.dart';

class WorkspaceWidget extends StatefulWidget {
  final String? locateWorkspaceTitle;
  final String? locateFolderTitle;

  const WorkspaceWidget(
      {super.key,
      required this.onSelectedWorkspace,
      required this.onSelectedFolder,
      this.locateWorkspaceTitle,
      this.locateFolderTitle});

  final void Function(WorkSpaceData? workSpaceData)? onSelectedWorkspace;
  final void Function(FolderData? folderData)? onSelectedFolder;

  @override
  State<WorkspaceWidget> createState() => _WorkspaceWidgetState();
}

class _WorkspaceWidgetState extends State<WorkspaceWidget> {
  late WorkSpaceController _workspaceController;
  late TreeController<tree_view.Node> _treeController;
  tree_view.Node _root = tree_view.Node(data: null);

  StreamSubscription? _close;
  FolderData? _selectedFolder;
  WorkSpaceData? _selectedWorkspace;
  final _fetchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));

  @override
  void initState() {
    updateSelectItem();
    super.initState();
    _treeController = _buildTreeController(_root);
    _workspaceController = Get.find<WorkSpaceController>();
    _close = _workspaceController.workspaces.stream.listen((data) {
      _fetchDebouncer.call(() {
        _treeController.dispose();
        _treeController = _buildTreeController(_root);
        fetchData();
      });
    });
    fetchData();
  }

  /// Updates the selected item in the workspace view.
  /// If [locateWorkspaceTitle] is null, the function returns early.
  /// Retrieves the workspace data using [locateWorkspaceTitle] and assigns it to [workSpaceData].
  /// If [workSpaceData] is null, the function returns early.
  /// Sets the expansion state of the root node in the tree controller to true.
  /// Searches for the workspace with an ID matching [workSpaceData.id] in the tree controller.
  /// Sets the expansion state of the matching workspace nodes to true.
  /// If [locateFolderTitle] is null, assigns [workSpaceData] to [_selectedWorkspace].
  /// If [locateFolderTitle] is not null and [locateFolderTitle] is different from the title of [_selectedFolder],
  /// retrieves the folder with [locateFolderTitle] and [workSpaceData.id] and assigns it to [_selectedFolder].
  /// Calls [onSelectedFolder] with [_selectedFolder] if it is not null.
  /// Rebuilds the tree controller.
  /// Calls [setState] to update the state of the widget.
  void updateSelectItem() async {
    if (widget.locateWorkspaceTitle == null) {
      return;
    }

    final workSpaceData =
        await _workspaceController.findWorkspace2(widget.locateWorkspaceTitle!);

    if (workSpaceData == null) return;

    _treeController.setExpansionState(_root, true);

    //展开workspace
    final res = _treeController.search((value) {
      if (value.data is WorkSpaceData) {
        final metaWorkSpaceData = value.data as WorkSpaceData;
        if (metaWorkSpaceData.id == workSpaceData.id) {
          return true;
        }
      }
      return false;
    });

    res.matches.forEach((key, value) {
      _treeController.setExpansionState(key, true);
    });

    if (widget.locateFolderTitle == null) {
      _selectedWorkspace = workSpaceData;
      widget.onSelectedWorkspace?.call(_selectedWorkspace);
      widget.onSelectedFolder?.call(null);
      _selectedFolder = null;
    }

    if (widget.locateFolderTitle != null &&
        (_selectedFolder == null ||
            widget.locateFolderTitle != _selectedFolder?.title)) {
      _selectedFolder = await _workspaceController.findFolder(
          widget.locateFolderTitle!, workSpaceData.id);

      widget.onSelectedFolder?.call(_selectedFolder);
    }

    _treeController.rebuild();

    if (mounted) {
      setState(() {});
    }
  }

  static TreeController<tree_view.Node> _buildTreeController(
      tree_view.Node root) {
    return tree_view.TreeControllerEx(
      roots: root.children,
      childrenProvider: (tree_view.Node node) => node.children,
      parentProvider: (tree_view.Node node) => node.parent,
    );
  }

  @override
  void didUpdateWidget(covariant WorkspaceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateSelectItem();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateSelectItem();
  }

  @override
  void dispose() {
    _treeController.dispose();
    _fetchDebouncer.cancel();
    _close?.cancel();
    super.dispose();
  }

  void fetchData() async {
    log.warn('workspace  fetchData');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final rootExpand = prefs.getBool('space_expand') ?? false;
    final root = tree_view.Node(data: null, onExpandChanged: onExpandChanged)
      ..isExpanded = rootExpand;
    for (var element in _workspaceController.workspaces) {
      final id = 'workspace_${element.id}_expand';
      final expand = prefs.getBool(id) ?? false;
      tree_view.Node<WorkSpaceData> workSpaceNode =
          tree_view.Node(data: element, onExpandChanged: onExpandChanged)
            ..isExpanded = expand
            ..setParent(root);
      element.dirs?.forEach((element) {
        workSpaceNode.addChildren(
            tree_view.Node(data: element)..setParent(workSpaceNode));
      });
      root.addChildren(workSpaceNode);
    }
    _treeController.roots = [root];
    _root = root;

    setState(() {});
  }

  void onExpandChanged(tree_view.Node node, bool isExpanded) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (node.data == null) {
      if (isExpanded) {
        prefs.setBool('space_expand', true);
      } else {
        prefs.remove('space_expand');
      }
    } else if (node.data is WorkSpaceData) {
      final workSpaceData = node.data as WorkSpaceData;
      final id = 'workspace_${workSpaceData.id}_expand';
      if (isExpanded) {
        prefs.setBool(id, true);
      } else {
        prefs.remove(id);
      }
    }
  }

  bool canAccept(tree_view.Node<dynamic> from, tree_view.Node<dynamic> to,
      tree_view.DropPositon dropPositon) {
    if (from.data == null) {
      return false;
    }

    if (from.data is FolderData && to.data == null) {
      return false;
    }

    if (from.data is WorkSpaceData && to.data == null) {
      if (dropPositon != tree_view.DropPositon.whenInside) return false;
    }

    if (from.data is WorkSpaceData && to.data is FolderData) {
      return false;
    }

    if (from.data is WorkSpaceData && to.data is WorkSpaceData) {
      if (dropPositon == tree_view.DropPositon.whenInside) return false;
    }

    if (from.data is FolderData && to.data is WorkSpaceData) {
      if (dropPositon != tree_view.DropPositon.whenInside) return false;
    }

    if (from.data is FolderData && to.data is FolderData) {
      if (dropPositon == tree_view.DropPositon.whenInside) return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return tree_view.DragAndDropTreeView(
      root: _root,
      treeController: _treeController,
      nodeWidgetBuilder: _buildNodeWidget,
      canAccept: canAccept,
      onNodeAccepted: onNodeAccepted,
    );
  }

  Widget _buildNodeWidget(tree_view.Node node) {
    if (node.data == null) {
      return _buildRootWidget(node);
    } else if (node.data is WorkSpaceData) {
      return _buildWorkspaceWidget(node);
    } else if (node.data is FolderData) {
      return _buildFolderWidget(node);
    }
    return Container();
  }

  Widget _buildRootWidget(tree_view.Node node) {
    return MouseRegionBuilder(builder: (context, entered) {
      return Container(
        padding: const EdgeInsets.only(left: 0, right: 5, top: 0, bottom: 0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'Space',
              style: ui.FluentTheme.of(context)
                  .typography
                  .title!
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 23.px),
            ).paddingAll(3),
            const Spacer(),
            entered
                ? GestureDetector(
                    onTap: onAddWorkSpace,
                    child: const Icon(
                      Icons.add,
                      size: 20,
                      color: Colors.grey,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      );
    });
  }

  Widget _buildWorkspaceWidget(tree_view.Node node) {
    final theme = ui.FluentTheme.of(context);
    return MouseRegionBuilder(builder: (context, entered) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Container(
              height: 30,
              decoration: entered
                  ? BoxDecoration(
                      color: theme.menuColor,
                      borderRadius: BorderRadius.circular(5))
                  : null,
              child: Row(
                children: [
                  MouseRegionBuilder(builder: (context, entered2) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedWorkspace = node.data as WorkSpaceData;
                          _selectedFolder = null;
                        });
                        widget.onSelectedFolder?.call(null);
                        widget.onSelectedWorkspace?.call(_selectedWorkspace);
                      },
                      child: Text(
                        (node.data as WorkSpaceData).title,
                        style: entered2
                            ? const TextStyle(
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                decorationThickness: 1.85,
                                decorationStyle: TextDecorationStyle.dashed,
                              )
                            : const TextStyle(fontSize: 13),
                      ).paddingOnly(left: 6),
                    );
                  }),
                  const Spacer(),
                  if (entered)
                    WorkSpacePopupButton(
                      onSelected: (val) {
                        if (val == 0) {
                          onRenameWorkSpace(node);
                        } else if (val == 1) {
                          onDelWorkspace(node);
                        }
                      },
                    ).marginOnly(right: 8),
                  entered
                      ? GestureDetector(
                          onTap: () {
                            onAddFolder(node);
                          },
                          child: const Icon(
                            Icons.add_circle,
                            size: 20,
                            color: Colors.grey,
                          ).marginOnly(right: 5),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFolderWidget(tree_view.Node node) {
    return MouseRegionBuilder(builder: (context, entered) {
      final selected = (node.data as FolderData).isSameTo(_selectedFolder);
      final theme = ui.FluentTheme.of(context);
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedFolder = node.data as FolderData;
            _selectedWorkspace = null;
          });
          widget.onSelectedFolder?.call(_selectedFolder);
          widget.onSelectedWorkspace?.call(_selectedWorkspace);
        },
        child: Container(
          height: 30,
          width: double.infinity,
          decoration: entered || selected
              ? BoxDecoration(
                  color: selected
                      ? theme.accentColor.lightest.withOpacity(0.2)
                      : theme.menuColor,
                  borderRadius: BorderRadius.circular(5))
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  (node.data as FolderData).title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: selected
                          ? theme.accentColor
                          : theme.typography.subtitle!.color, fontSize: 13),
                ).paddingOnly(left: 10, top: 0, bottom: 0, right: 5),
              ),
              entered
                  ? FolderPopupButton(
                      onSelected: (val) {
                        if (val == 2) {
                          showTaskCreateDialog(context,
                              initFolder: node.data as FolderData);
                        } else if (val == 0) {
                          onEditFolderName(node);
                        } else if (val == 1) {
                          onDeleteFolder(node);
                        }
                      },
                    ).marginOnly(right: 10)
                  : const SizedBox(),
            ],
          ),
        ),
      );
    });
  }

  void onEditFolderName(tree_view.Node node) async {
    final folderData = (node.data as FolderData);
    String? value =
        await showAddTextDialog(context, initContent: folderData.title);
    if (value == null || value.trim().isEmpty) return;

    if (_workspaceController.hasDuplicateFolder(
        node.parent!.data as WorkSpaceData, value)) {
      showToast(context, '提示', '名称重复，请重新输入');
      return;
    }

    final workSpaceData = node.parent!.data as WorkSpaceData;
    folderData.title = value;
    workSpaceData.updateTime = DateTime.now().millisecondsSinceEpoch;
    _workspaceController.updateWorkSpace(workSpaceData);
    node.data = folderData;
    _treeController.rebuild();
    setState(() {});
  }

  void onAddWorkSpace() async {
    String? value = await showAddTextDialog(context);
    if (value == null || value.trim().isEmpty) return;

    if (await _workspaceController.hasDuplicateWorkSpace(value)) {
      showToast(context, '提示', '名称重复，请重新输入');
      return;
    }

    final newWorkspace = WorkSpaceData()
      ..title = value.trim()
      ..status = Status.unknown
      ..createTime = DateTime.now().millisecondsSinceEpoch;

    _workspaceController.addWorkSpace(newWorkspace);
  }

  void onDeleteFolder(tree_view.Node node) async {
    final val = node.data as FolderData;
    if ((val.tasks != null && val.tasks!.isNotEmpty) ||
        (val.assets != null && val.assets!.isNotEmpty)) {
      showToast(context, '提示', '请先清空内容再删除', severity: ui.InfoBarSeverity.error);
      return;
    }

    var res = await showSelectedDialog(context, '提示', '确定删除么？');
    if (res == 1) {
      _workspaceController.deleteFolder(node.data as FolderData);

      // 删掉所有的tasks
      final taskController = GetInstance().find<TaskController>();

      final List<int> allIds = [];
      final tasks = await taskController.findTasks(val.tasks);
      if (val.tasks != null) {
        allIds.addAll(val.tasks!);
      }

      tasks?.forEach((task) {
        if (task.subTasks != null) {
          allIds.addAll(task.subTasks!);
        }
      });

      await taskController.deleteTasks(allIds);
      widget.onSelectedFolder?.call(null);
    }
  }

  void onAddFolder(tree_view.Node node) async {
    String? value = await showAddTextDialog(context);
    if (value == null || value.trim().isEmpty) return;

    final workSpaceData = (node.data as WorkSpaceData);

    if (_workspaceController.hasDuplicateFolder(workSpaceData, value)) {
      showToast(context, '提示', '名称重复，请重新输入');
      return;
    }

    var lists = workSpaceData.dirs?.toList();
    lists = lists ?? [];
    final newNode = FolderData()
      ..title = value.trim()
      ..parentId = workSpaceData.id
      ..createTime = DateTime.now().millisecondsSinceEpoch
      ..status = Status.unknown;
    lists.add(newNode);
    workSpaceData.dirs = lists;
    workSpaceData.updateTime = DateTime.now().millisecondsSinceEpoch;
    _workspaceController.updateWorkSpace(workSpaceData);
  }

  void onRenameWorkSpace(tree_view.Node node) async {
    final newWorkspace = node.data as WorkSpaceData;
    String? value =
        await showAddTextDialog(context, initContent: newWorkspace.title);
    if (value == null || value.trim().isEmpty) return;

    if (await _workspaceController.hasDuplicateWorkSpace(value)) {
      // ignore: use_build_context_synchronously
      showToast(context, '提示', '名称重复，请重新输入');
      return;
    }

    newWorkspace.title = value;

    _workspaceController.updateWorkSpace(newWorkspace);
  }

  void onDelWorkspace(tree_view.Node node) async {
    final folders = (node.data as WorkSpaceData).dirs ?? [];
    if (folders.isNotEmpty) {
      showToast(context, '提示', '请先清空内容再删除', severity: ui.InfoBarSeverity.error);
      return;
    }

    var res = await showSelectedDialog(context, '提示', '确定删除么？');
    if (res == 1) {
      _workspaceController.delWorkSpace(node.data as WorkSpaceData);

      widget.onSelectedFolder?.call(null);
      widget.onSelectedWorkspace?.call(null);
    }
  }

  void onNodeAccepted(tree_view.Node from, tree_view.Node target,
      tree_view.DropPositon dropPositon) async {
    if (from.data is FolderData &&
        target.data is WorkSpaceData &&
        dropPositon == tree_view.DropPositon.whenInside) {
      await moveFolderToOtherWorkspace(
          from.data, (target.data as WorkSpaceData).id);
    } else if (from.data is FolderData && target.data is FolderData) {
      if (dropPositon == tree_view.DropPositon.whenAbove ||
          dropPositon == tree_view.DropPositon.whenBelow) {
        final fromFolder = from.data as FolderData;
        final toFolder = target.data as FolderData;
        if (fromFolder.parentId == toFolder.parentId) {
          await adjustFolderPosition(fromFolder, toFolder, dropPositon);
        } else {
          await moveFolderToOtherWorkspace(fromFolder, toFolder.parentId);
          fromFolder.parentId = toFolder.parentId;
          await adjustFolderPosition(fromFolder, toFolder, dropPositon);
        }
      }
    } else if (from.data is WorkSpaceData &&
        target.data is WorkSpaceData &&
        dropPositon != tree_view.DropPositon.whenInside) {}
  }

  Future<void> adjustFolderPosition(FolderData fromFolder, FolderData toFolder,
      tree_view.DropPositon dropPositon) async {
    // 只改动相对位置
    final workspaceController = Get.find<WorkSpaceController>();

    final workSpaceData =
        await workspaceController.findWorkspace(fromFolder.parentId);

    workSpaceData?.insertFolder(
        fromFolder, toFolder, dropPositon == tree_view.DropPositon.whenAbove);

    await workspaceController.updateWorkSpace(workSpaceData!);
  }
}
