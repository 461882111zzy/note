import 'dart:async';
import 'dart:convert';

import 'package:dailyflowy/app/controllers/calendar_controller.dart';
import 'package:dailyflowy/app/data/meeting.dart';
import 'package:dailyflowy/app/data/meeting_ex.dart';
import 'package:dailyflowy/app/views/extensions/plugin/extension_manager.dart';
import 'package:dailyflowy/app/views/extensions/plugin/extensions.dart';
import 'package:dailyflowy/app/views/extensions/plugin/schedule_extension.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' as calendar;
import 'package:widget_kit_plugin/widget_kit_plugin.dart';

class MacosWidgetExtension {
  final _controller = Get.find<CalendarController>();
  List<Meeting> _meetings = [];
  void Function()? _close;
  StreamSubscription? _close1;
  late Timer _timer;
  bool _isPluginFetching = false;
  bool _isFirstFetch = true;
  Timer? _fetchExtensionMeetingTimer;

  MacosWidgetExtension() {
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

    _close1 = _controller.updateTime.listen((p0) {
      refresh();
    });
  }

  void dispose() {
    _close?.call();
    _close1?.cancel();
    _timer.cancel();
    _fetchExtensionMeetingTimer?.cancel();
  }

  void _onExtensionMeetings(List<MeetingEx>? value) {
    _fetchExtensionMeetingTimer?.cancel();
    _isPluginFetching = false;

    if (value != null) {
      final todays = _filterOnlyToday(value);
      if (todays.isEmpty) return;
      //清楚掉meetingex的数据，只保留meeting
      _meetings.removeWhere((element) => element is MeetingEx);

      _meetings = _mergeList(_meetings, todays);
    }

    _setWidgetExtensionData(_meetings);
  }

  List<Meeting> duplicate(List<Meeting> lists) {
    final res = <Meeting>[];
    for (int index = 0; index < lists.length; index++) {
      int find = res.indexWhere((element) => element.id == lists[index].id);
      if (find <= -1) {
        res.add(lists[index]);
      }
    }

    return res;
  }

  void refresh() async {
    final today = DateTime.now();
    _meetings = await _controller.findMeetingsByDate(today, today) ?? [];
    _meetings.addAll(await _loadRecurringMeetings());

    _meetings = duplicate(_meetings);

    _meetings = _mergeList(_meetings, []);
    if (_isFirstFetch) {
      _setWidgetExtensionData(_meetings);
      _isFirstFetch = false;
    }

    if (_isPluginFetching == true) return;
    _isPluginFetching = true;
    ScheduleExtension? extension = await ExtensionManager.instance
        .getExtension(ExtensionName.schedule.value);
    extension?.fetchMeetings(today, today);

    _fetchExtensionMeetingTimer?.cancel();
    _fetchExtensionMeetingTimer = Timer(const Duration(seconds: 2), () {
      _isPluginFetching = false;
      _setWidgetExtensionData(_meetings);
    });
  }

  Future<List<Meeting>> _loadRecurringMeetings() async {
    final List<Meeting> meetings = [];
    final recurring = await _controller.findRecurringMeetings();
    final today = DateTime.now();
    recurring?.forEach((meeting) {
      final rRule = meeting.recurrenceRule;
      final recurrenceStartDate = meeting.from;
      calendar.SfCalendar.getRecurrenceDateTimeCollection(
              rRule!, recurrenceStartDate!,
              specificStartDate: today.startOfDay(),
              specificEndDate: today.endOfDay().add(const Duration(days: 1)))
          .forEach((element) {
        if (element.isToday &&
            meetings.indexWhere((meta) => meta.id == meeting.id) < 0) {
          final duration = meeting.to!.difference(meeting.from!);
          final start = element;
          final end = start.add(duration);
          meeting.from = start;
          meeting.to = end;
          meetings.add(meeting);
        }
      });
    });
    return meetings;
  }

  List<Meeting> _mergeList(List<Meeting> q1, List<Meeting> q2) {
    List<Meeting> result = [];
    result.addAll(q1);
    result.addAll(q2);

    _sortByStartTime(result);
    result = _allDayToFirst(result);

    return result;
  }

  //sort result by from
  void _sortByStartTime(List<Meeting> data) {
    data.sort((a, b) {
      if (a.from == null) return 1;
      if (b.from == null) return -1;
      return a.from!.isBefore(b.from!) ? -1 : 1;
    });
  }

  List<Meeting> _allDayToFirst(List<Meeting> meetings) {
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

  List<Meeting> _filterOnlyToday(List<Meeting> meetings) {
    final today = DateTime.now();
    return meetings
        .where((meeting) =>
            meeting.from?.day == today.day &&
            meeting.from?.year == today.year &&
            meeting.from?.month == today.month)
        .toList();
  }
}

void _setWidgetExtensionData(List<Meeting> meetings) async {
  final today = DateTime.now();
  final json = meetings.map((e) {
    return {
      "startTime": ((e.from ?? today).millisecondsSinceEpoch / 1000).floor(),
      "endTime": ((e.to ?? today).millisecondsSinceEpoch / 1000).floor(),
      "title": e.title,
      "subtitle": e.notes ?? '',
      "isAllDay": e.isAllDay,
    };
  }).toList();
  UserDefaults.appGroup = 'groupdata';

  await UserDefaults.setString(
    'schedule',
    jsonEncode(json),
    'groupdata',
  ).then((_) {
    WidgetKit.reloadAllTimelines();
  });
}

final macosWidgetExt = MacosWidgetExtension();
