import 'dart:async';

import 'package:dailyflowy/app/controllers/task_controller.dart';
import 'package:dailyflowy/app/data/workspace.dart';
import 'package:dailyflowy/app/modules/2_taskboard/views/details_view.dart';
import 'package:dailyflowy/app/modules/2_taskboard/views/folder_over_view.dart';
import 'package:dailyflowy/app/modules/2_taskboard/views/workspace_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get_instance/src/get_instance.dart';
import 'package:fluent_ui/fluent_ui.dart' as ui;
import 'package:tiny_logger/tiny_logger.dart';

typedef LocateSetter = void Function(
    String? workspaceTitle, String? folderTitle);

class LocateController {
  LocateSetter? _onLocateSet;

  void setOnLocateSet(LocateSetter onLocateSet) {
    _onLocateSet = onLocateSet;
  }

  void locate(String? workspaceTitle, String? folderTitle) {
    _onLocateSet?.call(workspaceTitle, folderTitle);
  }
}

class IndexView2 extends StatefulWidget {
  final LocateController locateController;
  const IndexView2({super.key, required this.locateController});

  @override
  State<IndexView2> createState() => _IndexView2State();
}

class _IndexView2State extends State<IndexView2>   with AutomaticKeepAliveClientMixin {
  WorkSpaceData? _showWorkspaceSumary;
  FolderData? _showFolderContent;
  int _updateTime = DateTime.now().millisecondsSinceEpoch;
  StreamSubscription? _taskClose;

  String? _workspaceTitle;
  String? _folderTitle;

  @override
  void initState() {
    log.warn('_IndexView2State  initState');
    super.initState();
    _taskClose =
        GetInstance().find<TaskController>().updateTime.stream.listen((event) {
      setState(() {
        _updateTime = event;
      });
    });

    widget.locateController.setOnLocateSet(onLocateSet);
  }

  void onLocateSet(String? workspaceTitle, String? folderTitle) {
    _workspaceTitle = workspaceTitle;
    _folderTitle = folderTitle;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _taskClose?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant IndexView2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.locateController.setOnLocateSet(onLocateSet);
  }

  @override
  void didChangeDependencies() {
    widget.locateController.setOnLocateSet(onLocateSet);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
              margin: const EdgeInsets.only(top: 0),
              width: 200,
              child: WorkspaceWidget(
                  locateWorkspaceTitle: _workspaceTitle,
                  locateFolderTitle: _folderTitle,
                  onSelectedWorkspace: (_) {
                    if (_showWorkspaceSumary != _) {
                      setState(() {
                        _showWorkspaceSumary = _;
                        _showFolderContent = null;
                        _workspaceTitle = _!.title;
                        _folderTitle = null;
                      });
                    }
                  },
                  onSelectedFolder: (_) {
                    if (_showFolderContent != _) {
                      setState(() {
                        _showWorkspaceSumary = null;
                        _showFolderContent = _;
                        _workspaceTitle = null;
                        _folderTitle = null;
                      });
                    }
                  })),
          const SizedBox(
            width: 5,
          ),
          const ui.Divider(direction: Axis.vertical),
          Expanded(
              child: Container(
            child: _showFolderContent != null
                ? TaskDetailsWidget(
                    folderData: _showFolderContent,
                    timestamp: _updateTime,
                  )
                : _showWorkspaceSumary != null
                    ? FolderOverViewWidget(workSpaceData: _showWorkspaceSumary)
                    : Container(),
          ))
        ],
      ),
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}
