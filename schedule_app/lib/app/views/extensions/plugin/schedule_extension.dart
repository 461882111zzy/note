import 'package:dailyflowy/app/data/meeting_ex.dart';
import 'package:dailyflowy/app/views/extensions/plugin/extension_base.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:tiny_logger/tiny_logger.dart';

/*
   'fetchMeetings', [from, to]
    onMeetingsData: [{'from': xxx, 'to': xxx, 'title':xxx, 'notes': xxx}]
 */

class ScheduleExtension extends ExtensionBase {
  final List<void Function(List<MeetingEx>?)> _listeners = [];

  static ExtensionBase Function() creator() {
    return () {
      return ScheduleExtension();
    };
  }

  @override
  String name() => 'schedule';

  @override
  void onInit() {
    run();
  }

  void fetchMeetings(DateTime from, DateTime to) {
    final start = from.startOfDay();
    final end = to.endOfDay();
    log.debug(
        'fetchMeetings ex : ${start.toIso8601String()} - ${end.toIso8601String()}');
    sendMessage('fetchMeetings',
        ['${start.millisecondsSinceEpoch}', '${end.millisecondsSinceEpoch}']);
  }

  void Function() addMeetingsDataListener(
      void Function(List<MeetingEx>?) listener) {
    _listeners.add(listener);
    return (() {
      _listeners.remove(listener);
    });
  }

  @override
  Map<String, dynamic Function(dynamic p1)> getOnMessageHandlers() {
    return {'onMeetingsData': _onMeetingsData};
  }

  dynamic _onMeetingsData(dynamic data) {
    List<MeetingEx>? meetings = [];
    if (data is List) {
      for (Map element in data) {
        DateTime from =
            DateTime.fromMillisecondsSinceEpoch((element['from'] as int));
        DateTime to =
            DateTime.fromMillisecondsSinceEpoch((element['to'] as int));

        String title = element['title'] as String;
        String note = element['note'] as String;
        String id = element['id'] as String;
        final meeting = MeetingEx()
          ..from = from
          ..to = to
          ..identify = id
          ..isAllDay = false
          ..title = title
          ..notes = note;
        meetings.add(meeting);
      }
    } else {
      meetings = null;
    }
    for (var element in _listeners) {
      element(meetings);
    }
    return;
  }
}
