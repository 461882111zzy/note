import 'package:dailyflowy/app/controllers/holiday_controller.dart';
import 'package:dailyflowy/app/data/appointment_ex.dart';
import 'package:dailyflowy/app/views/meeting/appointment_details_view.dart';
import 'package:dailyflowy/app/views/calendar/calender_data_source.dart';
import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:dailyflowy/app/views/widgets/popup_button.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:fluent_ui/fluent_ui.dart' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dailyflowy/app/controllers/calendar_controller.dart'
    as meetting_data;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tiny_logger/tiny_logger.dart';

class IndexView extends StatefulWidget {
  const IndexView({super.key});

  @override
  State<IndexView> createState() => _BigCalendarViewState();
}

class _BigCalendarViewState extends State<IndexView>
    with AutomaticKeepAliveClientMixin {
  final CalendarController _calendarController = CalendarController();
  final HolidayController _holidayController = Get.find<HolidayController>();
  final DataSource _meetingDataSource = DataSource([]);
  final meetting_data.CalendarController _calendarDataController =
      Get.find<meetting_data.CalendarController>();
  DateTime? _dragOrResizeStartTime;
  int _updateTime = 0;

  @override
  void initState() {
    _calendarController.view = CalendarView.month;
    super.initState();
    loadConfig();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadConfig() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    _calendarController.view =
        sharedPreferences.getBool('CalendarView_month') == true
            ? CalendarView.month
            : CalendarView.week;
    setState(() {});
  }

  void saveConfig() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(
        'CalendarView_month', _calendarController.view == CalendarView.month);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 50, right: 20, left: 10),
      child: Localizations.override(
        context: context,
        locale: const Locale('zh'),
        child: Stack(
          children: [
            LayoutBuilder(builder: (context, constants) {
              return SfCalendar(
                view: CalendarView.month,
                controller: _calendarController,
                dataSource: _meetingDataSource,
                showTodayButton: false,
                cellBorderColor: Colors.grey,
                showDatePickerButton: true,
                showNavigationArrow: true,
                headerDateFormat: 'MMMM yyyy',
                showWeekNumber: true,
                allowDragAndDrop: true,
                allowAppointmentResize: true,
                timeSlotViewSettings: const TimeSlotViewSettings(
                  minimumAppointmentDuration: Duration(minutes: 30),
                ),
                weekNumberStyle: WeekNumberStyle(
                  textStyle: TextStyle(
                    color: ui.FluentTheme.of(context).accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                headerStyle: CalendarHeaderStyle(
                  backgroundColor: Colors.transparent,
                  textStyle: TextStyle(
                    color: ui.FluentTheme.of(context).accentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                monthViewSettings: MonthViewSettings(
                  appointmentDisplayCount: constants.maxHeight / 6 > 110
                      ? constants.maxHeight / 6 > 150
                          ? 5
                          : 4
                      : 3,
                  appointmentDisplayMode:
                      MonthAppointmentDisplayMode.appointment,
                  showTrailingAndLeadingDates: false,
                ),
                monthCellBuilder: _buildCellWidget,
                appointmentBuilder: _getAppointmentUI,
                loadMoreWidgetBuilder: (BuildContext context,
                    LoadMoreCallback loadMoreAppointments) {
                  return FutureBuilder<void>(
                    future: loadMoreAppointments(),
                    builder:
                        (BuildContext context, AsyncSnapshot<void> snapShot) {
                      return const SizedBox(
                        width: 1,
                        height: 1,
                      );
                    },
                  );
                },
                onDragStart: (AppointmentDragStartDetails details) {
                  Appointment appointment = details.appointment! as Appointment;
                  _dragOrResizeStartTime = appointment.startTime;
                },
                onAppointmentResizeStart:
                    (AppointmentResizeStartDetails details) {
                  Appointment appointment = details.appointment! as Appointment;
                  _dragOrResizeStartTime = appointment.startTime;
                },
                onDragEnd: (AppointmentDragEndDetails details) {
                  _onUpdateAppointment(details.appointment! as Appointment);
                },
                onAppointmentResizeEnd: (AppointmentResizeEndDetails details) {
                  _onUpdateAppointment(details.appointment! as Appointment);
                },
              );
            }),
            Align(
              alignment: Alignment.topCenter,
              child: MouseRegionBuilder(builder: (context, _) {
                return CupertinoSegmentedControl(
                    unselectedColor: Colors.transparent,
                    groupValue:
                        _calendarController.view == CalendarView.week ? 0 : 1,
                    children: {
                      0: Text(
                        '周',
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.0,
                            color: _calendarController.view == CalendarView.week
                                ? Colors.white
                                : ui.FluentTheme.of(context).selectionColor),
                      ).marginSymmetric(horizontal: 40),
                      1: Text(
                        '月',
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.0,
                            color: _calendarController.view ==
                                    CalendarView.month
                                ? Colors.white
                                : ui.FluentTheme.of(context).selectionColor),
                      ),
                    },
                    onValueChanged: (int value) {
                      _calendarController.view =
                          value == 0 ? CalendarView.week : CalendarView.month;
                      setState(() {});
                      saveConfig();
                    });
              }),
            ).paddingOnly(right: 50, top: 4),
            Align(
                alignment: Alignment.topRight,
                child: ui.SizedBox(
                  height: 29,
                  child: ui.Button(
                      onPressed: () {
                        _calendarController.selectedDate = DateTime.now();
                        _calendarController.displayDate = DateTime.now();
                      },
                      child: const Text(
                        '今天',
                        style: TextStyle(fontSize: 12),
                      )),
                )).marginOnly(top: 4),
          ],
        ),
      ),
    );
  }

  Widget _getAppointmentUI(
      BuildContext context, CalendarAppointmentDetails details) {
    if (details.isMoreAppointmentRegion) {
      return const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '+ More',
            style: TextStyle(fontSize: 10, height: 1.0),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ));
    }

    final Appointment meeting = details.appointments.first;
    Widget widget = Container(
      alignment: Alignment.centerLeft,
      color: meeting.color.withOpacity(0.3),
      child: LayoutBuilder(builder: (context, constants) {
        double height = constants.maxHeight * 0.8;
        if (height > 13) {
          height = 13;
        }

        final content = Row(
          children: [
            Container(
              width: 4,
              height: constants.maxHeight,
              color: meeting.color,
              margin: const EdgeInsets.only(right: 3),
            ),
            Expanded(
              child: Text(
                meeting.subject,
                style: TextStyle(
                  height: 1.0,
                  fontSize: height,
                ),
                maxLines: (constants.maxHeight / height).floor(),
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );

        if (meeting.recurrenceRule != null && meeting.recurrenceRule != '') {
          return Stack(
            children: [
              Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.repeat,
                    size: 14,
                    color: ui.FluentTheme.of(context).accentColor.lighter,
                  )),
              content
            ],
          );
        } else {
          return content;
        }
      }),
    );
    // }

    widget = PopupButton(
      direction: PopupDirection.top,
      builder: (context) {
        return AppointmentDetails(appointment: meeting);
      },
      child: widget,
    );

    return widget;
  }

  void _onUpdateAppointment(Appointment newAppointment) {
    if (newAppointment is AppointmentEx || newAppointment.id is! int) {
      newAppointment.startTime =
          _dragOrResizeStartTime ?? newAppointment.startTime;
      _meetingDataSource.updateData(newAppointment);
      log.debug('onUpdateAppointment: newAppointment is AppointmentEx');
    } else {
      print('_onUpdateAppointment:$newAppointment');

      final id =
          newAppointment.appointmentType == AppointmentType.changedOccurrence
              ? newAppointment.recurrenceId
              : newAppointment.id;
      
      // 去底层数据更新
      _calendarDataController.findMeetings([id as int]).then((value) {
        print('_onUpdateAppointment, value :$value');
        if (value != null && value.isNotEmpty) {
          print('_onUpdateAppointment, value :${value[0]}');
          value[0].from = newAppointment.startTime;
          value[0].to = newAppointment.endTime;
          value[0].isAllDay = newAppointment.isAllDay;
          _updateTime = DateTime.now().millisecondsSinceEpoch;
          _calendarDataController.updateMeeting(value[0],
              millisecondsSinceEpoch: _updateTime);
        }
      });

      _meetingDataSource.handleRemoveData(newAppointment.id as int);

    }
    _dragOrResizeStartTime = null;
  }

  Widget _buildCellWidget(BuildContext context, MonthCellDetails cellDetails) {
    final theme = ui.FluentTheme.of(context);
    if (_calendarController.view == CalendarView.month) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final isBefore = cellDetails.date.isBefore(today);
      final isToday = cellDetails.date.isSameDate(today);
      final lunar = getLunarDayText(cellDetails.date);
      final holiday = _holidayController.findHolidayInfo(cellDetails.date);
      final dayType = holiday != null
          ? (holiday.dayType == DayType.vacation ? "休" : "班")
          : null;

      final showDate =
          _calendarController.selectedDate ?? _calendarController.displayDate;

      final isSelectedToday =
          (showDate != null ? showDate.isSameDate(cellDetails.date) : false);

      Color? getColor() {
        return isToday
            ? (isSelectedToday
                ? theme.typography.subtitle!.color
                : theme.accentColor)
            : isSelectedToday
                ? theme.typography.subtitle!.color
                : theme.typography.body!.color;
      }

      return Container(
        width: cellDetails.bounds.width,
        height: cellDetails.bounds.height,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: isToday
                ? (isSelectedToday
                    ? theme.accentColor
                    : theme.accentColor.withOpacity(0.2))
                : Colors.grey.withOpacity(0.5),
            width: 0.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (dayType != null ? '  ' : '') +
                          cellDetails.date.day.toString(),
                      style: TextStyle(
                          fontSize: 15,
                          color: isBefore ? Colors.grey : getColor()),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        dayType ?? "",
                        style: TextStyle(
                            color: isBefore ? Colors.grey : Colors.redAccent,
                            fontSize: 10),
                      ),
                    ),
                  ],
                ),
                Text(
                  holiday?.name ?? lunar,
                  style: TextStyle(
                      height: 1,
                      color: isBefore ? Colors.grey : getColor(),
                      fontSize: 9),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.only(right: 2)),
          ],
        ),
      );
    } else {
      final int yearValue = (cellDetails.date.year ~/ 10) * 10;
      return Container(
        width: cellDetails.bounds.width,
        height: cellDetails.bounds.height,
        alignment: Alignment.center,
        child: Text('$yearValue - ${yearValue + 9}'),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
