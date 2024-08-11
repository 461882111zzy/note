import 'dart:async';
import 'dart:io';

import 'package:dailyflowy/app/controllers/calendar_controller.dart';
import 'package:dailyflowy/app/data/meeting.dart';
import 'package:dailyflowy/app/data/meeting_ex.dart';
import 'package:dailyflowy/app/modules/0_home/controllers/home_controller.dart';
import 'package:dailyflowy/app/views/extensions/plugin/extension_manager.dart';
import 'package:dailyflowy/app/views/extensions/plugin/extensions.dart';
import 'package:dailyflowy/app/views/extensions/plugin/schedule_extension.dart';
import 'package:dailyflowy/app/views/widgets/mouse_hover_builder.dart';
import 'package:dailyflowy/app/views/widgets/move_window.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' as calendar;

class MiniModeWidget extends StatefulWidget {
  const MiniModeWidget({super.key});

  @override
  MiniModeWidgetState createState() => MiniModeWidgetState();
}

class MiniModeWidgetState extends State<MiniModeWidget> {
  final _controller = Get.find<CalendarController>();
  List<Meeting> _meetings = [];
  void Function()? _close;
  late Timer _timer;
  bool _isPluginFetching = false;

  @override
  void initState() {
    super.initState();
    ExtensionManager.instance
        .getExtension<ScheduleExtension>(ExtensionName.schedule.value)
        .then((value) {
      if (value != null) {
        _close = value.addMeetingsDataListener(_onExtensionMeetings);
      } else {
        _close = () {};
      }
    });
    refresh();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      refresh();
    });
  }

  @override
  void dispose() {
    _close?.call();
    _timer.cancel();
    super.dispose();
  }

  Widget buildScheduleView() {
    final now = DateTime.now();
    return ListView.builder(
      itemCount: _meetings.length,
      itemBuilder: (context, index) {
        var scheduleItem = _meetings[index];
        var isExpired =
            scheduleItem.to != null && scheduleItem.to!.isBefore(now);
        var isCurrent = scheduleItem.from != null &&
            scheduleItem.from!.isBefore(now) &&
            (scheduleItem.to == null || scheduleItem.to!.isAfter(now));

        Color itemColor;
        if (isExpired) {
          itemColor = Colors.grey;
        } else if (isCurrent) {
          itemColor = Colors.orangeAccent;
        } else {
          itemColor = Colors.blueAccent;
        }

        if (scheduleItem.isAllDay) itemColor = Colors.blueAccent;

        return IntrinsicHeight(
          child: Container(
            margin: const EdgeInsets.only(left: 4, right: 4, bottom: 6, top: 6),
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                if (scheduleItem.isAllDay)
                  const Text(
                    '全天',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ).marginOnly(left: 4, right: 14),
                if (!scheduleItem.isAllDay)
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(scheduleItem.from!),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: itemColor,
                          height: 1.0,
                        ),
                      ),
                      Text('-',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              height: 0.2,
                              color: itemColor)),
                      Text(DateFormat('HH:mm').format(scheduleItem.to!),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                              color: itemColor)),
                    ],
                  ).marginOnly(right: 8, left: 0),
                VerticalDivider(
                  thickness: 5,
                  color: itemColor,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        scheduleItem.title,
                        textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: false),
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 14, height: 1.2),
                      ).marginOnly(left: 2, top: 4),
                      if (scheduleItem.notes != null &&
                          scheduleItem.notes!.isNotEmpty &&
                          scheduleItem.notes!.trim().isNotEmpty)
                        Text(
                          scheduleItem.notes ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 10, height: 1.0),
                        ).marginOnly(bottom: 4, left: 2, top: 10, right: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildButton(IconData icon, void Function() onPressed) {
    return MouseHoverBuilder(builder: (context, enter) {
      return CupertinoButton(
        borderRadius: BorderRadius.circular(0),
        padding: EdgeInsets.zero,
        minSize: 30,
        color: enter ? Colors.grey.withOpacity(0.2) : Colors.transparent,
        onPressed: onPressed,
        child: Icon(
          icon,
          color: Colors.black54,
          size: 16,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MoveWindowDetector(
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: Platform.isWindows
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                if (Platform.isMacOS) const Spacer(),
                buildButton(CupertinoIcons.fullscreen, () {
                  Get.find<HomeController>().changeMode();
                }),
                buildButton(CupertinoIcons.refresh, () {
                  refresh();
                }),
              ],
            ).marginOnly(bottom: 4),
            Text('今天是：${formatChineseDate(DateTime.now())}')
                .marginOnly(left: 4, bottom: 4),
            Expanded(
                child: _meetings.isNotEmpty
                    ? buildScheduleView()
                    : const Center(child: Text('暂无日程'))),
          ],
        ),
      ),
    );
  }

  String formatChineseDate(DateTime date) {
    final formatter = DateFormat('yyyy年MM月dd日', 'zh_CN');
    return formatter.format(date);
  }

  void refresh() async {
    final today = DateTime.now();
    _meetings = await _controller.findMeetingsByDate(today, today) ?? [];
    _meetings.addAll(await _loadRecurringMeetings());
    _meetings = mergeList(_meetings, []);
    setState(() {});

    if (_isPluginFetching == true) return;
    _isPluginFetching = true;
    ScheduleExtension? extension = await ExtensionManager.instance
        .getExtension(ExtensionName.schedule.value);
    extension?.fetchMeetings(today, today);

    Future.delayed(const Duration(seconds: 2), () {
      _isPluginFetching = false;
    });
  }

  Future<List<Meeting>> _loadRecurringMeetings() async {
    final List<Meeting> meetings = [];
    final recurring = await _controller.findRecurringMeetings();

    recurring?.forEach((meeting) {
      final rRule = meeting.recurrenceRule;
      final recurrenceStartDate = meeting.from;
      final today = DateTime.now();
      calendar.SfCalendar.getRecurrenceDateTimeCollection(
              rRule!, recurrenceStartDate!,
              specificStartDate: today, specificEndDate: today)
          .forEach((element) {
        if (element.isToday) {
          meetings.add(meeting);
        }
      });
    });
    return meetings;
  }

  void _onExtensionMeetings(List<MeetingEx>? value) {
    _isPluginFetching = false;
    if(value == null){
      return;
    }
    _meetings = mergeList(_meetings, filterOnlyToday(value));
    setState(() {});
  }

  List<Meeting> mergeList(List<Meeting> q1, List<Meeting> q2) {
    List<Meeting> result = [];
    result.addAll(q1);
    result.addAll(q2);

    sortByStartTime(result);
    result = allDayToFirst(result);

    return result;
  }

  //sort result by from
  void sortByStartTime(List<Meeting> data) {
    data.sort((a, b) {
      if (a.from == null) return 1;
      if (b.from == null) return -1;
      return a.from!.isBefore(b.from!) ? -1 : 1;
    });
  }

  List<Meeting> allDayToFirst(List<Meeting> meetings) {
    final res = <Meeting>[];
    for (var meeting in meetings) {
      if (meeting.isAllDay) {
        res.insert(0, meeting);
      } else {
        res.add(meeting);
      }
    }
    return res;
  }

  List<Meeting> filterOnlyToday(List<Meeting> meetings) {
    final today = DateTime.now();
    return meetings
        .where((meeting) =>
            meeting.from?.day == today.day &&
            meeting.from?.year == today.year &&
            meeting.from?.month == today.month)
        .toList();
  }
}
