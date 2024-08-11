import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:dailyflowy/app/controllers/assets_controller.dart';
import 'package:dailyflowy/app/controllers/utils.dart';
import 'package:dailyflowy/app/controllers/workspace_controller.dart';
import 'package:dailyflowy/app/data/asset.dart';
import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:dailyflowy/app/views/widgets/selected_dialog.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:dailyflowy/app/views/widgets/text_editor.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/workspace.dart';
import '../tree_drop_down_button.dart';
import 'editor.dart';

void showNoteEditDialog(
    BuildContext context, int? noteId, FolderData? selectedFolder) {
  final theme = fluent.FluentTheme.of(context);
  fluent.showDialog(
    context: context,
    barrierDismissible: false,
    dismissWithEsc: false,
    barrierColor: theme.dialogTheme.barrierColor,
    builder: (BuildContext context) {
      return DocumentPage(
        noteId: noteId,
        selectedFolder: selectedFolder,
      );
    },
  );
}

class DocumentPage extends StatefulWidget {
  final int? noteId;
  final FolderData? selectedFolder;
  const DocumentPage({
    Key? key,
    this.noteId,
    this.selectedFolder,
  }) : super(key: key);

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  final TextEditingController _textEditingController = TextEditingController();
  EditorState _editorState = EditorState.blank();
  FolderData? _defaultFolder;
  FolderData? _selectedFolder;

  final AssetsController assetsController = Get.find<AssetsController>();

  @override
  void initState() {
    // The appflowy editor use Intl as localization, set the default language as fallback.
    Intl.defaultLocale = 'zh_CN';
    _defaultFolder = widget.selectedFolder;
    if (_defaultFolder == null && widget.noteId != null) {
      final workSpaceController = Get.find<WorkSpaceController>();
      _defaultFolder = workSpaceController.findByAssetId(widget.noteId!);
    }
    _initNoteContent();
    super.initState();
  }

  void _initNoteContent() async {
    if (widget.noteId != null) {
      final doc = await assetsController.findAssetDatas([widget.noteId!]);
      if (doc != null && doc.isNotEmpty) {
        final docData = doc[0];

        if (docData.type == assetTypeNote) {
          _textEditingController.text = docData.title;
          _editorState = EditorState(
              document: Document.fromJson(jsonDecode(docData.content!)));
          setState(() {});
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = fluent.FluentTheme.of(context);
    return Dialog(
      child: fluent.FlyoutContent(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            fluent.Row(
              crossAxisAlignment: fluent.CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextEditior(
                    controller: _textEditingController,
                    placeholder: '请输入标题',
                    maxLength: 40,
                    fontColor: theme.brightness == Brightness.light
                        ? const Color(0xFF282828)
                        : null,
                    fontSize: 40.px,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () async {
                    if (widget.noteId != null) {
                      _saveAndExit(context);
                    } else {
                      if (_textEditingController.text.isNotEmpty ||
                          !_editorState.document.isEmpty) {
                        if (1 ==
                            // ignore: use_build_context_synchronously
                            await showSelectedDialog(
                                context, '提示', '输入内容不为空，放弃?')) {
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                          return;
                        }
                      } else {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                ),
              ],
            ).marginOnly(left: 30, right: 20, top: 10, bottom: 10),
            Expanded(
              child: _renderDocument(context),
            ),
            if (widget.noteId == null)
              Align(
                alignment: Alignment.bottomRight,
                child: fluent.SizedBox(
                  width: 180.px,
                  height: 80.px,
                  child: MouseRegionBuilder(builder: (context, _) {
                    return fluent.FilledButton(
                      onPressed: () {
                        if (_textEditingController.text.isEmpty) {
                          showToast(context, '提示', '请输入标题');
                          return;
                        }

                        if (_editorState.document.isEmpty) {
                          showToast(context, '提示', '请输入内容');
                          return;
                        }

                        _saveAndExit(context);
                      },
                      child: const Text(
                        '创建',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ).marginOnly(bottom: 20, right: 30);
                  }),
                ),
              )
          ],
        ),
      ),
    );
  }

  void _saveAndExit(BuildContext context) async {
    if (_selectedFolder == null && _defaultFolder == null) {
      showToast(context, '提示', '请选择所属的项目');
      return;
    }

    final content = jsonEncode(_editorState.document.toJson());
    if (widget.noteId != null) {
      final doc = await assetsController.findAssetDatas([widget.noteId!]);
      if (doc != null && doc.isNotEmpty) {
        final docData = doc[0];

        if (docData.title == _textEditingController.text &&
            docData.content == content &&
            _defaultFolder == _selectedFolder) {
          Navigator.of(context).pop();
          return;
        }

        docData.title = _textEditingController.text;
        docData.content = content;

        docData.updateTime = DateTime.now().millisecondsSinceEpoch;
        await assetsController.updateAssetData(docData);

        final destFolder = _selectedFolder ?? _defaultFolder;
        if (destFolder != null) {
          await moveAssetBetweenFolder(docData, _defaultFolder, destFolder);
        }
      }
    } else {
      final destFolder = _selectedFolder ?? _defaultFolder;
      final workSpaceController = Get.find<WorkSpaceController>();
      _selectedFolder = await workSpaceController.findFolder(
          destFolder!.title, destFolder.parentId);

      AssetData docData = AssetData();
      docData.title = _textEditingController.text;
      docData.content = content;
      docData.type = assetTypeNote;
      docData.createTime = DateTime.now().millisecondsSinceEpoch;
      final id = await assetsController.addAssetData(docData);
      _selectedFolder?.addAsset(id);
      await workSpaceController.updateFolder(_selectedFolder!);
    }

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  Widget _renderDocument(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, bottom: 10, left: 30, right: 30),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 268.px,
              child: TreeDropDownButton(
                selectedFolder: _defaultFolder,
                onSelected: (data) {
                  _selectedFolder = data;
                },
              ),
            ),
          ).marginOnly(bottom: 20),
          Expanded(child: AppFlowyEditorWidget(editorState: _editorState)),
        ],
      ),
    );
  }
}

