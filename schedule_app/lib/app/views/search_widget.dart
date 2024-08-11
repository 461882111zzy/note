import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:dailyflowy/app/controllers/assets_controller.dart';
import 'package:dailyflowy/app/controllers/calendar_controller.dart';
import 'package:dailyflowy/app/controllers/docs_controller.dart';
import 'package:dailyflowy/app/controllers/task_controller.dart';
import 'package:dailyflowy/app/controllers/utils.dart';
import 'package:dailyflowy/app/data/asset.dart';
import 'package:dailyflowy/app/data/base_data.dart';
import 'package:dailyflowy/app/data/docs.dart';
import 'package:dailyflowy/app/data/meeting.dart';
import 'package:dailyflowy/app/data/task.dart';
import 'package:dailyflowy/app/data/utils.dart';
import 'package:dailyflowy/app/views/meeting/appointment_dialog.dart';
import 'package:dailyflowy/app/views/note/docs_edit.dart';
import 'package:dailyflowy/app/views/task/edit_task.dart';
import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:fluent_ui/fluent_ui.dart' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/popupover/popover.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({
    super.key,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  //输入框控制器
  final TextEditingController _controller = TextEditingController(text: '');
  bool _showResults = false;
  String _searchText = '';
  final _popoverController = PopoverController();
  final List<BaseData> _searchResult = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Popover(
      controller: _popoverController,
      direction: PopoverDirection.bottomWithLeftAligned,
      child: CupertinoSearchTextField(
        padding:
            const EdgeInsets.only(left: 5.5, top: 4, right: 5.5, bottom: 4),
        controller: _controller,
        borderRadius: BorderRadius.circular(6),
        suffixIcon: const Icon(
          CupertinoIcons.xmark_circle_fill,
          size: 15,
        ),
        autofocus: true,
        style: TextStyle(
            fontSize: 15.px,
            color: ui.FluentTheme.of(context).typography.subtitle!.color),
        prefixIcon: Image.asset(
          'images/search_small.png',
          width: 14.px,
          height: 14.px,
          isAntiAlias: true,
        ),
        prefixInsets: EdgeInsets.only(left: 10.px, right: 3.px),
        placeholder: '搜索',
        placeholderStyle: TextStyle(
            fontSize: 15.px,
            color: ui.FluentTheme.of(context)
                .typography
                .subtitle!
                .color!
                .withOpacity(0.5)),
        onTap: () async {
          if (_searchText.isEmpty) {
            return;
          }
          await search();
          if (_showResults) {
            _popoverController.show();
          } else {
            _popoverController.close();
          }
          setState(() {});
        },
        onChanged: (String value) async {
          if (value.isEmpty) {
            _searchText = '';
            _searchResult.clear();
          } else if (value == _searchText) {
            return;
          }
          _searchText = value;
          _showResults = value.isNotEmpty;
          await search();
          if (_showResults) {
            _popoverController.show();
          } else {
            _popoverController.close();
          }
          setState(() {});
        },
      ),
      popupBuilder: (context) {
        return ui.FlyoutContent(
          padding: const EdgeInsets.all(0),
          child: SizedBox(
              width: 554.px,
              height: 300,
              child: _searchResult.isNotEmpty
                  ? _buildResultView()
                  : const Center(
                      child: Text('没有找到结果'),
                    )),
        );
      },
    );
  }

  ListView _buildResultView() {
    final theme = ui.FluentTheme.of(context);
    return ListView.builder(
      itemCount: _searchResult.length,
      itemBuilder: (context, index) {
        String title = '';
        String content = '';
        IconData icon = Icons.deck;
        BaseData data = _searchResult[index];
        if (data is Task) {
          title = data.title;
          content = data.desc ?? '';
          icon = Icons.task_alt;
        } else if (data is DocData) {
          title = data.title;
          content = Document.fromJson(jsonDecode(data.content!)).toPlainText();
          icon = Icons.note;
        } else if (data is Meeting) {
          title = data.title;
          content = data.notes ?? '';
          icon = Icons.calendar_today;
        } else if (data is AssetData) {
          title = data.title;
          if (data.type == assetTypeNote) {
            content =
                Document.fromJson(jsonDecode(data.content!)).toPlainText();

            icon = Icons.note;
          } else if (data.type == assetTypeLink) {
            content = (jsonDecode(data.content!) as Map)['url'];
            icon = Icons.link;
          }
        }
        Widget widget = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _popoverController.close();
            if (data is Meeting) {
              editAppointmentDialog(context, meeting: data);
            } else if (data is Task) {
              showTaskEditDialog(context, data);
            } else if (data is DocData) {
              showNoteEditDialog(context, data.id, null);
            } else if (data is AssetData) {
              if (data.type == assetTypeNote) {
                showNoteEditDialog(context, data.id, null);
              } else if (data.type == assetTypeLink) {
                final content = jsonDecode(data.content!) as Map;
                launchUrl(Uri.parse(content['url']));
              }
            }
          },
          child: MouseRegionBuilder(builder: (context, entered) {
            return Container(
              color: entered
                  ? ui.FluentTheme.of(context).menuColor
                  : Colors.transparent,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20.px,
                    color: theme.accentColor,
                  ).marginOnly(left: 15.px, right: 15.px),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 10.px,
                        ),
                        _buildTitleText(title, _searchText),
                        _buildSubTitleText(content, _searchText),
                        SizedBox(
                          height: 10.px,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        );

        widget = Column(
          mainAxisSize: MainAxisSize.min,
          children: [widget, const ui.Divider()],
        );

        return widget;
      },
    );
  }

  Widget _buildTitleText(String text, String keyword) {
    final theme = ui.FluentTheme.of(context);
    int titleMatch = text.indexOf(keyword);
    return RichText(
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      text: TextSpan(
        text: titleMatch == -1
            ? text
            : text.substring(
                0,
                titleMatch,
              ),
        style: TextStyle(fontSize: 18.px, color: theme.typography.body!.color),
        children: text.contains(_searchText)
            ? [
                TextSpan(
                  text: text.substring(
                    text.indexOf(_searchText),
                    text.indexOf(_searchText) + _searchText.length,
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme
                        .accentColor, // You can change the highlight color here
                  ),
                ),
                TextSpan(
                  text: text.substring(
                      text.indexOf(_searchText) + _searchText.length),
                  style: TextStyle(color: theme.typography.body!.color
                      // You can change the highlight color here
                      ),
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildSubTitleText(String rawText, String keyword) {
    final theme = ui.FluentTheme.of(context);
    final String text = (toPlainText(rawText, 1000) ?? '').replaceAll('\n', '');
    if (text.isEmpty) {
      return Container();
    }
    int titleMatch = text.indexOf(keyword);
    return RichText(
      softWrap: false,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        text: titleMatch == -1
            ? text
            : (titleMatch - 15 > 0 ? '...' : '') +
                text.substring(
                  titleMatch - 15 > 0 ? titleMatch - 15 : 0,
                  titleMatch,
                ),
        style: TextStyle(fontSize: 16.px, color: Colors.grey),
        children: text.contains(_searchText)
            ? [
                TextSpan(
                  text: text.substring(
                    text.indexOf(_searchText),
                    text.indexOf(_searchText) + _searchText.length,
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme
                        .accentColor, // You can change the highlight color here
                  ),
                ),
                TextSpan(
                  text: text.substring(
                      text.indexOf(_searchText) + _searchText.length),
                  style: const TextStyle(
                    color:
                        Colors.grey, // You can change the highlight color here
                  ),
                ),
              ]
            : [],
      ),
    );
  }

  Future<void> search() async {
    final calendarController = Get.find<CalendarController>();
    final docsController = Get.find<DocsController>();
    final taskController = Get.find<TaskController>();
    final assetController = Get.find<AssetsController>();

    final res1 = await calendarController.searchMeetings(_searchText);
    final res3 = await docsController.searchNotes(_searchText);
    final res4 = await taskController.searchTasks(_searchText);
    final res5 = await assetController.searchAssetDatasFilterType(
      assetTypeNote,
      _searchText,
    );
    final res6 = await assetController.searchAssetDatasFilterType(
        assetTypeLink, _searchText);

    _searchResult.clear();
    if (res1 != null) {
      _searchResult.addAll(res1);
    }
    if (res3 != null) {
      _searchResult.addAll(res3);
    }
    if (res4 != null) {
      _searchResult.addAll(res4);
    }
    if (res5 != null) {
      _searchResult.addAll(res5);
    }
    if (res6 != null) {
      _searchResult.addAll(res6);
    }
  }
}
