import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailyflowy/app/controllers/assets_controller.dart';
import 'package:dailyflowy/app/controllers/utils.dart';
import 'package:dailyflowy/app/controllers/workspace_controller.dart';
import 'package:dailyflowy/app/data/asset.dart';
import 'package:dailyflowy/app/data/workspace.dart';
import 'package:dailyflowy/app/theme.dart';
import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:dailyflowy/app/views/widgets/selected_dialog.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:fluent_ui/fluent_ui.dart' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:get/get.dart';

import '../../../views/note/url_launcher.dart';

class AssetsWidget extends StatefulWidget {
  final FolderData folderData;
  const AssetsWidget({super.key, required this.folderData});

  @override
  State<AssetsWidget> createState() => _AssetsWidgetState();
}

class _AssetsWidgetState extends State<AssetsWidget>
    with AutomaticKeepAliveClientMixin {
  final AssetsController _assetsController = Get.find<AssetsController>();
  List<AssetData> _assets = [];
  StreamSubscription<int>? _close;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _close = _assetsController.updateTime.stream.listen((event) {
      _assets.clear();
      fetchAssetsData();
    });
    fetchAssetsData();
  }

  @override
  void didUpdateWidget(covariant AssetsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.folderData.parentId != widget.folderData.parentId ||
        oldWidget.folderData.title != widget.folderData.title ||
        oldWidget.folderData.assets != widget.folderData.assets) {
      _assets.clear();
      fetchAssetsData();
    }
  }

  @override
  void dispose() {
    _close?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    int index = 0;
    List<AssetData> tmp = [];
    tmp.addAll(_assets);
    return Column(
      crossAxisAlignment: ui.CrossAxisAlignment.stretch,
      mainAxisSize: ui.MainAxisSize.max,
      children: [
        const ui.Divider(
          direction: Axis.horizontal,
          style: ui.DividerThemeData(
              verticalMargin: EdgeInsets.zero,
              horizontalMargin: EdgeInsets.zero),
        ),
        _buildOperationArea(context).marginOnly(top: 5, left: 10),
        ui.Expanded(
          child: ui.SingleChildScrollView(
                  child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: tmp.map((e) {
                        index++;
                        return _buildAssetCard(index, e);
                      }).toList()))
              .marginOnly(left: 10, right: 10, bottom: 20, top: 5),
        ),
      ],
    );
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
            showAddAssetsDialog(context);
          },
        ),
      ],
    );
  }

  MouseRegionBuilder buildAddLink() {
    return MouseRegionBuilder(builder: (context, entered) {
      return GestureDetector(
        onTap: () {
          showAddAssetsDialog(context);
        },
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: ui.FluentTheme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                  offset: const Offset(0, 1),
                  color: ui.FluentTheme.of(context).shadowColor.withAlpha(100),
                  blurStyle: ui.BlurStyle.outer,
                  blurRadius: 0.5)
            ],
          ),
          child: Stack(alignment: Alignment.center, children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(alignment: Alignment.center, children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add,
                        size: 40,
                      ).marginOnly(bottom: 10),
                      const Text(
                        'Add Link',
                        style: TextStyle(fontSize: 13),
                      )
                    ],
                  ),
                ])
              ],
            ),
          ]),
        ),
      );
    });
  }

  Widget _buildAssetCard(int index, AssetData e) {
    final content = jsonDecode(_assets[index - 1].content!) as Map;
    var previewData = content['preview'] != null
        ? PreviewData.fromJson(content['preview'])
        : null;
    if (previewData != null) {
      previewData = previewData.copyWith(
          title: e.title.isNotEmpty ? e.title : previewData.title);
    }
    return MouseRegionBuilder(builder: (context, entered) {
      return SizedBox(
        width: 220,
        height: 180,
        child: Stack(
          children: [
            LinkPreview(
              key: ValueKey(content['url']),
              previewBuilder: (buildContext, previewData) {
                return CustomLinkPreviewWidget(
                  title: e.title.isEmpty
                      ? previewData.title ?? content['url']
                      : e.title,
                  url: previewData.link ?? content['url'],
                  description: previewData.description,
                  imageUrl: previewData.image?.url,
                );
              },
              enableAnimation: true,
              onPreviewDataFetched: (data) {
                updateAssetData(index, data, content);
              },
              text: content['url'],
              width: 260,
              previewData: previewData,
            ),
            if (entered)
              GestureDetector(
                onTap: () async {
                  final res = await showSelectedDialog(context, '提示', '确认移除么?');

                  if (res == 1) {
                    int assetId = _assets[index - 1].id;
                    await _assetsController
                        .deleteAssetData(_assets[index - 1].id);
                    _assets.remove(e);
                    final workSpaceController = Get.find<WorkSpaceController>();
                    final lastFolder = await workSpaceController.findFolder(
                        widget.folderData.title, widget.folderData.parentId);

                    if (lastFolder != null) {
                      final assets = <int>[...?lastFolder.assets];
                      assets.remove(assetId);
                      lastFolder.assets = assets;
                      await workSpaceController.updateFolder(lastFolder);
                    }

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
      );
    });
  }

  void updateAssetData(
      int index, PreviewData data, Map<dynamic, dynamic> content) {
    final assetData = _assets[index - 1];
    assetData
      ..title = assetData.title.isNotEmpty
          ? assetData.title
          : (data.title ?? content['url'])
      ..content = jsonEncode({'preview': data.toJson(), 'url': content['url']});
    _assetsController.updateAssetData(assetData);

    setState(() {
      _assets[index - 1] = assetData;
    });
  }

  void fetchAssetsData() async {
    await widget.folderData.update();

    final assets = await _assetsController.findAssetDatasFilterType(
        widget.folderData.assets, assetTypeLink);
    _assets = (assets ?? [])
      ..retainWhere((element) => element.type == assetTypeLink);
    setState(() {});
  }

  Future<int?> showAddAssetsDialog(BuildContext context) async {
    TextEditingController titleEditingController = TextEditingController();
    TextEditingController linkEditingController = TextEditingController();
    return ui.showDialog<int>(
      context: context,
      barrierColor: Colors.black12,
      builder: (BuildContext context) {
        return ui.ContentDialog(
          title: const Text('添加链接'),
          content: _buildInputWidget(
              context, titleEditingController, linkEditingController),
          actions: <Widget>[
            ui.Button(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(0);
              },
            ),
            ui.FilledButton(
              child: const Text('确认'),
              onPressed: () async {
                if (linkEditingController.text.isEmpty) {
                  showToast(context, '提示', '必须输入链接',
                      severity: ui.InfoBarSeverity.warning);
                  return;
                }

                _onAddLink(
                    titleEditingController.text, linkEditingController.text);

                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(1);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputWidget(
      BuildContext context,
      TextEditingController titleEditingController,
      TextEditingController linkEditingController) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ui.TextBox(
          controller: titleEditingController,
          placeholder: '名称',
        ).marginOnly(bottom: 10),
        ui.TextBox(
          controller: linkEditingController,
          placeholder: '网址',
        ).marginOnly(bottom: 10),
      ],
    );
  }

  Future<void> _onAddLink(String? title, String value) async {
    try {
      Uri.parse(value);
    } catch (e) {
      showToast(context, '提示', '链接格式错误');
      return;
    }
    final assetData = AssetData();
    assetData.type = assetTypeLink;
    try {
      final previewData = await getPreviewData(value);
      assetData.title =
          title!.isNotEmpty ? title : (previewData.title ?? value);
      assetData.content =
          jsonEncode({'preview': previewData.toJson(), 'url': value});
    } catch (e) {
      assetData.title = title ?? value;
      assetData.content = jsonEncode({'iconUrl': '', 'url': value});
    }
    await _assetsController.addAssetData(assetData);
    _assets.add(assetData);

    final workSpaceController = Get.find<WorkSpaceController>();
    final lastFolder = await workSpaceController.findFolder(
        widget.folderData.title, widget.folderData.parentId);
    if (lastFolder != null) {
      lastFolder.assets = _assets.map((e) => e.id).toList();
      await workSpaceController.updateFolder(lastFolder);
    }

    setState(() {});
  }
}

class CustomLinkPreviewWidget extends StatelessWidget {
  const CustomLinkPreviewWidget({
    super.key,
    required this.url,
    this.title,
    this.description,
    this.imageUrl,
  });

  final String? title;
  final String? description;
  final String? imageUrl;
  final String url;

  @override
  Widget build(BuildContext context) {
    final theme = ui.FluentTheme.of(context);
    final fontSize = 18.px;
    final Widget child = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.extension<CardBoardColor>()!.color),
        borderRadius: BorderRadius.circular(
          6.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 4.0,
                      right: 10.0,
                    ),
                    child: Text(
                      title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                Text(
                  url.toString(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: fontSize - 4,
                    height: 1.1,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                if (description != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0, top: 4.0),
                    child: Text(
                      description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        height: 1.1,
                        fontSize: fontSize - 4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ui.Expanded(
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: imageUrl ?? '',
              errorWidget: (context, url, error) {
                return Icon(Icons.link_outlined,
                    size: 50, color: Colors.grey.withAlpha(100));
              },
            ),
          ),
        ],
      ),
    );

    return InkWell(
      onTap: () => afLaunchUrlString(url),
      child: child,
    );
  }
}
