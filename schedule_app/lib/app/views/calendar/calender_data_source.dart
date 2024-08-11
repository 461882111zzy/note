import 'dart:async';

import 'package:dailyflowy/app/controllers/calendar_controller.dart'
    as meetting_data;
import 'package:dailyflowy/app/data/appointment_ex.dart';
import 'package:dailyflowy/app/data/meeting.dart';
import 'package:dailyflowy/app/data/meeting_ex.dart';
import 'package:dailyflowy/app/views/extensions/plugin/extension_manager.dart';
import 'package:dailyflowy/app/views/extensions/plugin/extensions.dart';
import 'package:dailyflowy/app/views/extensions/plugin/schedule_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:lunar_calendar_converter_new/lunar_solar_converter.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tiny_logger/tiny_logger.dart';

class DataSource extends CalendarDataSource {
  late void Function() _pluginClose;
  late StreamSubscription? _addEventclose;
  late StreamSubscription? _removeEventclose;

  final meetting_data.CalendarController _calendarDataController =
      Get.find<meetting_data.CalendarController>();

  bool _isLoadedrecurrenceMeetings = false;

  Future<(List<Appointment>, List<Appointment>)> fetchMeetings(
      DateTime from, DateTime end) async {
    return _transMeetingsToAppointment(
        await _calendarDataController.findMeetingsByDate(from, end) ?? []);
  }

  (List<Appointment>, List<Appointment>) _transMeetingsToAppointment(
      List<Meeting> meetings) {
    List<Appointment> appointmentAdd = [];
    List<Appointment> appointmentUpdate = [];
    meetings
        .map((e) {
          if (e is MeetingEx) {
            return AppointmentEx(
              startTime: e.from ?? e.to!,
              endTime: e.to!,
              subject: e.title,
              notes: e.notes,
              isAllDay: e.isAllDay,
              id: e.identify,
              color: e.background != null
                  ? Color(e.background!)
                  : const Color(0xFF49DCBB),
            );
          } else {
            return Appointment(
              startTime: e.from ?? e.to!,
              endTime: e.to!,
              subject: e.title,
              notes: e.notes,
              isAllDay: e.isAllDay,
              id: e.id,
              recurrenceRule: e.recurrenceRule
                  ?.replaceAll('BYMONTHDAY=0', 'BYMONTHDAY=1')
                  .replaceAll('BYMONTH=0', 'BYMONTH=1'),
              color: e.background != null
                  ? Color(e.background!)
                  : const Color(0xFF538FFF),
            );
          }
        })
        .toList()
        .forEach((element) {
          bool find = false;
          for (int i = 0; i < appointments!.length; i++) {
            //已有的会议，要更新
            if (element.id == (appointments![i] as Appointment).id) {
              appointmentUpdate.add(element);
              find = true;
              break;
            }
          }
          if (!find) {
            appointmentAdd.add(element);
          }
        });
    return (appointmentAdd, appointmentUpdate);
  }

  DataSource(List<Appointment> source) {
    appointments = source;
    _addEventclose =
        _calendarDataController.lastUpdateMeetings.listen((value) async {
      final res = _transMeetingsToAppointment([value]);
      handleAddData(res.$1);
      handleUpdateData(res.$2);
    });

    _removeEventclose =
        _calendarDataController.lastRemoveMeetings.listen((value) async {
      for (var id in value) {
        handleRemoveData(id);
      }
    });

    ExtensionManager.instance
        .getExtension<ScheduleExtension>(ExtensionName.schedule.value)
        .then((value) {
      if (value != null) {
        _pluginClose = value.addMeetingsDataListener(_onExtensionMeetings);
      } else {
        _pluginClose = () {};
      }
    });
  }

  void updateData(Appointment appointment) {
    handleUpdateData([appointment]);
  }

  void handleUpdateData(List<Appointment> appointmentNeed) {
    if (appointmentNeed.isEmpty) return;
    if (appointments == null) return;

    for (var elemenNeedt in appointmentNeed) {
      for (int index = 0; index < appointments!.length; index++) {
        Appointment element = appointments![index];
        if (element.id == elemenNeedt.id) {
          element = elemenNeedt;
          appointments![index] = elemenNeedt;
          break;
        }
      }
    }

    notifyListeners(CalendarDataSourceAction.reset, appointmentNeed);
  }

  void _onExtensionMeetings(List<MeetingEx>? meetings) {
    _isLoadedrecurrenceMeetings = false;
    if (meetings == null) {
      return;
    }

    if (meetings.isNotEmpty) {
      log.debug(meetings[0].title);
    }

    final (appointmentAdd, appointmentUpdate) =
        _transMeetingsToAppointment(meetings);

    handleAddData(appointmentAdd);
    handleUpdateData(appointmentUpdate);
  }

  @override
  void dispose() {
    _pluginClose();
    _addEventclose?.cancel();
    _removeEventclose?.cancel();
    super.dispose();
  }

  @override
  Future<void> handleLoadMore(DateTime startDate, DateTime endDate) {
    final completer = Completer();
    fetchMeetings(startDate, endDate).then((value) async {
      final recurring = await _loadRecurringMeetings();
      handleAddData(duplicate([...value.$1, ...recurring.$1]));
      handleUpdateData(duplicate([...value.$2, ...recurring.$2]));

      completer.complete();
    });
    log.debug(
        'handleLoadMore: ${startDate.toIso8601String()} - ${endDate.toIso8601String()}');
    // 触发扩展执行
    _loadExtensionMeeting(startDate, endDate);

    return completer.future;
  }

  List<Appointment> duplicate(List<Appointment> lists) {
    final res = <Appointment>[];
    for (int index = 0; index < lists.length; index++) {
      int find = res.indexWhere((element) => element.id == lists[index].id);
      if (find <= -1) {
        res.add(lists[index]);
      }
    }

    return res;
  }

  Future<(List<Appointment>, List<Appointment>)>
      _loadRecurringMeetings() async {
    if (!_isLoadedrecurrenceMeetings) {
      _isLoadedrecurrenceMeetings = true;

      return _transMeetingsToAppointment(
          await _calendarDataController.findRecurringMeetings() ?? []);
    }
    return (<Appointment>[], <Appointment>[]);
  }

  void _loadExtensionMeeting(DateTime startDate, DateTime endDate) async {
    ScheduleExtension? extension = await ExtensionManager.instance
        .getExtension(ExtensionName.schedule.value);
    extension?.fetchMeetings(startDate, endDate);
  }

  void handleRemoveData(Id id) {
    final appointment = [];
    appointments?.removeWhere((element) {
      if (id == (element as Appointment).id) {
        appointment.add(element);
        return true;
      }
      return false;
    });
    notifyListeners(CalendarDataSourceAction.remove, appointment);
  }

  void handleAddData(List<Appointment> meeting) {
    if (meeting.isEmpty) return;
    appointments?.addAll(meeting);
    notifyListeners(CalendarDataSourceAction.add, meeting);
  }
}

String getLunarDayText(DateTime date) {
  // ignore: no_leading_underscores_for_local_identifiers
  final List<String> _lunarMonthList = [
    '正',
    '二',
    '三',
    '四',
    '五',
    '六',
    '七',
    '八',
    '九',
    '十',
    '冬',
    '腊'
  ];
  final List<String> lunarDayList = [
    '初一',
    '初二',
    '初三',
    '初四',
    '初五',
    '初六',
    '初七',
    '初八',
    '初九',
    '初十',
    '十一',
    '十二',
    '十三',
    '十四',
    '十五',
    '十六',
    '十七',
    '十八',
    '十九',
    '二十',
    '廿一',
    '廿二',
    '廿三',
    '廿四',
    '廿五',
    '廿六',
    '廿七',
    '廿八',
    '廿九',
    '三十'
  ];

  final lunar = LunarSolarConverter.solarToLunar(
      Solar(solarYear: date.year, solarMonth: date.month, solarDay: date.day));
  if (lunar.lunarMonth != null) {
    String month = _lunarMonthList[lunar.lunarMonth! - 1];
    String leap = lunar.isLeap ? "闰" : "";
    String result = "$leap$month月";

    if (lunar.lunarDay != null && lunar.lunarDay != 1) {
      result = lunarDayList[lunar.lunarDay! - 1];
    }

    return result;
  }

  return '';
}
