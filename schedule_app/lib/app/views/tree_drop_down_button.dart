import 'dart:async';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:dailyflowy/app/controllers/workspace_controller.dart';
import 'package:dailyflowy/app/data/base_data.dart';
import 'package:dailyflowy/app/data/workspace.dart';
import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluent_ui/fluent_ui.dart' as ui;
import 'widgets/popup_button.dart';

class TreeDropDownButton extends StatefulWidget {
  final void Function(FolderData data) onSelected;
  final FolderData? selectedFolder;
  const TreeDropDownButton(
      {super.key, required this.onSelected, this.selectedFolder});

  @override
  State<TreeDropDownButton> createState() => _TreeDropDownButtonState();
}

class _TreeDropDownButtonState extends State<TreeDropDownButton> {
  late WorkSpaceController _workspaceController;
  var _node = TreeNode<BaseData>.root();
  StreamSubscription? _close;
  FolderData? _selectedFolder;

  @override
  void initState() {
    _selectedFolder = widget.selectedFolder;
    _workspaceController = GetInstance().find<WorkSpaceController>(tag: null);
    _close = _workspaceController.workspaces.stream.listen((data) {
      fetchData();
    });

    fetchData();

    super.initState();
  }

  void fetchData() {
    var newNode = TreeNode<BaseData>.root();
    for (var element in _workspaceController.workspaces) {
      TreeNode<WorkSpaceData> workSpaceNode = TreeNode(data: element);
      if (_selectedFolder?.parentId == element.id) {
        workSpaceNode.expansionNotifier.value = true;
      }
      element.dirs?.forEach((element) {
        workSpaceNode.add(TreeNode(data: element));
      });
      newNode.add(workSpaceNode);
    }

    setState(() {
      _node = newNode;
    });
  }

  @override
  void dispose() {
    _close?.cancel();
    super.dispose();
  }

  Widget _buildFoldersView(BuildContext context) {
    final theme = ui.FluentTheme.of(context);
    return TreeView.simple(
        tree: _node,
        padding: EdgeInsets.zero,
        showRootNode: false,
        indentation: const Indentation(width: 0),
        expansionIndicatorBuilder: noExpansionIndicatorBuilder,
        expansionBehavior: ExpansionBehavior.none,
        builder: (context, node) {
          if (node.level == 0) {
            return MouseRegionBuilder(builder: (context, entered) {
              return Container(
                padding:
                    const EdgeInsets.only(left: 0, right: 5, top: 5, bottom: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      node.isExpanded
                          ? Icons.arrow_drop_down
                          : Icons.arrow_right,
                      size: 20,
                      color: Colors.grey,
                    ),
                    Text(
                      '工作空间',
                      style: TextStyle(
                          fontSize: 12,
                          color: theme.typography.subtitle!.color),
                    ).paddingAll(3),
                  ],
                ),
              );
            });
          } else if (node.level == 1) {
            return MouseRegionBuilder(builder: (context, entered) {
              return Container(
                padding:
                    const EdgeInsets.only(left: 0, right: 5, top: 0, bottom: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    node.isLeaf
                        ? const SizedBox(
                            width: 20,
                          )
                        : Icon(
                            node.isExpanded
                                ? Icons.arrow_drop_down
                                : Icons.arrow_right,
                            size: 20,
                            color: Colors.grey,
                          ),
                    Expanded(
                      child: Container(
                        height: 25,
                        decoration: entered
                            ? BoxDecoration(
                                color: theme.accentColor.withAlpha(50),
                                borderRadius: BorderRadius.circular(5))
                            : null,
                        child: Row(
                          children: [
                            Text(
                              (node.data as WorkSpaceData).title,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: theme.typography.subtitle!.color),
                            ).paddingOnly(left: 3),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
          } else {
            return MouseRegionBuilder(builder: (context, entered) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFolder = node.data as FolderData;
                  });
                  Navigator.of(context).pop();

                  widget.onSelected(node.data as FolderData);
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                      left: 20, right: 5, top: 2, bottom: 2),
                  decoration:
                      entered || isSelectedFoler(node.data as FolderData)
                          ? BoxDecoration(
                              color: theme.accentColor.withAlpha(50),
                              borderRadius: BorderRadius.circular(5))
                          : null,
                  child: Text(
                    (node.data as FolderData).title,
                    style: TextStyle(
                        fontSize: 12, color: theme.typography.subtitle!.color),
                  ).paddingOnly(left: 6, top: 5, bottom: 5, right: 5),
                ),
              );
            });
          }
        }).marginOnly(top: 5);
  }

  bool isSelectedFoler(FolderData data) {
    if (null == _selectedFolder) {
      return false;
    }

    return data.title == _selectedFolder!.title &&
        data.parentId == _selectedFolder!.parentId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ui.FluentTheme.of(context);
    return SizedBox(
      width: 268.px,
      child: MouseRegionBuilder(builder: (context, entered) {
        return PopupButton(
          direction: PopupDirection.bottom,
          offset: Offset.zero,
          enableFeedback: false,
          builder: (context) {
            return SizedBox(
              width: 268.px,
              height: 180,
              child: Card(
                color: theme.brightness == Brightness.light
                    ? Colors.white
                    : theme.acrylicBackgroundColor,
                child: _buildFoldersView(context),
              ),
            );
          },
          child: Container(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(ui.FluentIcons.fabric_folder_link,
                    size: 12,
                    color: _selectedFolder == null && !entered
                        ? const Color(0xFFA8A8A8)
                        : theme.typography.subtitle!.color),
                const SizedBox(width: 5),
                Text(
                  _selectedFolder != null ? _selectedFolder!.title : '关联项目',
                  style: TextStyle(
                      fontSize: 17.px,
                      color: _selectedFolder != null || entered
                          ? theme.typography.subtitle!.color
                          : const Color(0xFFADADAD)),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
