import 'package:dailyflowy/app/views/calendar/calendar_view.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as ui;

import 'due_date_view.dart';
import 'line_up_view.dart';
import 'recent_view.dart';

class IndexView extends StatefulWidget {
  const IndexView({Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _IndexViewState createState() => _IndexViewState();
}

class _IndexViewState extends State<IndexView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
        final theme = ui.FluentTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(left: 10),
      width: double.infinity,
      height: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 8,
            child: ListView(
              children: const [
                LineUpWidget(),
                DueDateActivityWidget(),
                RecentActivityWidget(),
              ],
            ),
          ),
          Container(
            width: 385.px,
            decoration: BoxDecoration(
                color: theme.acrylicBackgroundColor,
                borderRadius: BorderRadius.circular(20.px)),
            margin: EdgeInsets.only(
                left: 17.px, bottom: 20.px, top: 10.px, right: 10.px),
            child: const CalendarWidget(),
          )
        ],
      ),
    );
  }
}
