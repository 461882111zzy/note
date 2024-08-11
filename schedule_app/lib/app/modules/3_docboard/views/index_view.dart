import 'dart:async';
import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:dailyflowy/app/controllers/utils.dart';
import 'package:dailyflowy/app/controllers/workspace_controller.dart';

import 'package:dailyflowy/app/data/asset.dart';
import 'package:dailyflowy/app/data/workspace.dart';
import 'package:dailyflowy/app/views/note/docs_edit.dart';
import 'package:dailyflowy/app/views/note_preview.dart';
import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:fluent_ui/fluent_ui.dart' as ui;
import 'package:flutter/material.dart';
import 'package:dailyflowy/app/controllers/assets_controller.dart';

import 'package:get/get.dart';

class IndexView extends StatefulWidget {
  const IndexView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _IndexViewState createState() => _IndexViewState();
}

class _ShowData {
  late AssetData data;
  late String sumary;
  FolderData? folderData;
}

class _IndexViewState extends State<IndexView> {
  final AssetsController assetsController = Get.find();
  final List<_ShowData> _assetDatas = [];
  bool _isEnd = false;
  late StreamSubscription close;

  @override
  void initState() {
    super.initState();
    fetchData();

    close = assetsController.updateTime.listen((p0) {
      reset();
      fetchData();
    });
  }

  void reset() {
    _isEnd = false;
    _assetDatas.clear();
  }

  @override
  void dispose() {
    close.cancel();
    super.dispose();
  }

  void fetchData() async {
    if (_isEnd) {
      return;
    }
    final assetDatas = await assetsController.getAssetDatasFilterType(
        assetTypeNote, _assetDatas.length, 10);
    if (assetDatas != null && assetDatas.length == 10) {
    } else {
      _isEnd = true;
    }

    final workSpaceController = Get.find<WorkSpaceController>();
    await workSpaceController.asureInstance();

    if (assetDatas != null) {
      final newDatas = assetDatas.map<_ShowData>((e) {
        final folderData = workSpaceController.findByAssetId(e.id);
        return _ShowData()
          ..data = e
          ..folderData = folderData
          ..sumary =
              Document.fromJson(jsonDecode(e.content!)).sumary(maxLength: 150);
      }).toList();

      for (var newData in newDatas) {
        if (_assetDatas.indexWhere((element) {
              return element.data.id == newData.data.id;
            }) >=
            0) {
        } else {
          _assetDatas.add(newData);
        }
      }
    }
    setState(() {});
  }

  void deleteNoteData(int index) async {
    final assetData = _assetDatas[index].data;
    await assetsController.deleteAssetData(assetData.id);
    final folderData = _assetDatas[index].folderData;
    _assetDatas.removeAt(index);
    setState(() {});

    if (folderData == null) return;

    final List<int> newAssets = [];
    newAssets.addAll(folderData.assets!);
    newAssets.remove(assetData.id);
    folderData.assets = newAssets;
    final workSpaceController = Get.find<WorkSpaceController>();
    await workSpaceController.updateFolder(folderData);
    setState(() {});
  }

  Future<void> _showDeleteDialog(int index) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: const Text('确定删除么?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
    if (confirmDelete != null && confirmDelete) {
      deleteNoteData(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ui.FluentTheme.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth ~/ 250,
              childAspectRatio: 1.78,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10),
          itemCount: _assetDatas.length,
          padding: const EdgeInsets.all(20),
          itemBuilder: (BuildContext context, int index) {
            if (index == _assetDatas.length - 1) {
              fetchData();
            }
            return MouseRegionBuilder(builder: (context, entered) {
              final item = _assetDatas[index];
              return GestureDetector(
                onTap: () {
                  showNoteEditDialog(context, item.data.id, item.folderData);
                },
                child: SizedBox(
                  width: 250,
                  height: 140,
                  child: Stack(
                    children: [
                      NotePreview(
                          title: item.data.title,
                          folderTitle: item.folderData?.title,
                          updateTime:
                              item.data.updateTime ?? item.data.createTime,
                          sumary: item.sumary),
                      if (entered)
                        GestureDetector(
                          onTap: () async {
                            await _showDeleteDialog(index);
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
          },
        );
      },
    );
  }
}
