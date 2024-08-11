import 'dart:async';
import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:dailyflowy/app/controllers/assets_controller.dart';
import 'package:dailyflowy/app/controllers/utils.dart';
import 'package:dailyflowy/app/data/asset.dart';
import 'package:dailyflowy/app/data/workspace.dart';
import 'package:dailyflowy/app/views/note/docs_edit.dart';
import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:dailyflowy/app/views/widgets/selected_dialog.dart';
import 'package:fluent_ui/fluent_ui.dart' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/workspace_controller.dart';
import '../../../views/note_preview.dart';

class _ShowData {
  late AssetData data;
  late String sumary;
  FolderData? folderData;
}

class NotesWidget extends StatefulWidget {
  final FolderData folderData;
  const NotesWidget({super.key, required this.folderData});

  @override
  State<NotesWidget> createState() => _NotesWidgetState();
}

class _NotesWidgetState extends State<NotesWidget>
    with AutomaticKeepAliveClientMixin {
  final AssetsController _assetsController = Get.find<AssetsController>();
  StreamSubscription<int>? _close;
  final List<_ShowData> _assetDatas = [];
  bool _isLoadingData = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _close = _assetsController.updateTime.stream.listen((event) {
      forceRefreshData();
    });
    forceRefreshData();
  }

  @override
  void dispose() {
    _close?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NotesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.folderData.parentId != widget.folderData.parentId ||
        oldWidget.folderData.title != widget.folderData.title ||
        oldWidget.folderData.assets != widget.folderData.assets) {
      forceRefreshData();
    }
  }

  Widget _buildOperationArea(BuildContext context) {
    return ui.CommandBar(
      isCompact: false,
      overflowBehavior: ui.CommandBarOverflowBehavior.noWrap,
      primaryItems: [
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
            showNoteEditDialog(context, null, widget.folderData);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        const ui.Divider(
          direction: Axis.horizontal,
          style: ui.DividerThemeData(
              verticalMargin: EdgeInsets.zero,
              horizontalMargin: EdgeInsets.zero),
        ),
        _buildOperationArea(context).marginOnly(top: 5, left: 10),
        if (_assetDatas.isNotEmpty)
          ui.Expanded(
            child: ui.SingleChildScrollView(
                    child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _assetDatas.map((e) {
                          return _buildAssetCard(e);
                        }).toList()))
                .marginOnly(left: 10, right: 10, bottom: 20, top: 5),
          ),
        if (_assetDatas.isEmpty)
          ui.Expanded(
            child: ui.Center(
              child: Image.asset(
                'images/notes_big.png',
                width: 300,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAssetCard(_ShowData e) {
    final theme = ui.FluentTheme.of(context);
    return MouseRegionBuilder(builder: (context, entered) {
      return GestureDetector(
        onTap: () {
          if (e.data.type == assetTypeNote) {
            showNoteEditDialog(context, e.data.id, widget.folderData);
          }
        },
        child: SizedBox(
          width: 250,
          height: 140,
          child: Stack(
            children: [
              NotePreview(
                  title: e.data.title,
                  updateTime: e.data.updateTime ?? e.data.createTime,
                  sumary: e.sumary),
              if (entered)
                GestureDetector(
                  onTap: () async {
                    final res =
                        await showSelectedDialog(context, '提示', '确认移除么?');

                    if (res == 1) {
                      _assetsController.deleteAssetData(e.data.id);
                      setState(() {});
                    }
                  },
                  child: Align(
                    alignment: Alignment.topRight,
                    child: const Icon(
                      Icons.delete,
                      size: 16,
                      color: Colors.grey,
                    ).marginOnly(right: 6, top: 6),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  void forceRefreshData() async {
    if (_isLoadingData) return;
    _isLoadingData = true;
    _assetDatas.clear();
    await fetchAssetsData();
    _isLoadingData = false;
  }

  Future<void> fetchAssetsData() async {
    await widget.folderData.update();
    var assets = await _assetsController.findAssetDatasFilterType(
            widget.folderData.assets, assetTypeNote) ??
        [];
    assets.retainWhere((element) => element.type == assetTypeNote);

    final workSpaceController = Get.find<WorkSpaceController>();
    await workSpaceController.asureInstance();

    _assetDatas.addAll(assets.map<_ShowData>((e) {
      final folderData = workSpaceController.findByAssetId(e.id);
      return _ShowData()
        ..data = e
        ..folderData = folderData
        ..sumary =
            Document.fromJson(jsonDecode(e.content!)).sumary(maxLength: 150);
    }).toList());

    setState(() {});
  }
}
