import 'dart:async';

import 'package:dailyflowy/app/controllers/holiday_controller.dart';
import 'package:dailyflowy/app/views/calendar/calender_data_source.dart';
import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:fluent_ui/fluent_ui.dart' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../modules/0_home/controllers/home_controller.dart';
import '../meeting/appointment_details_view.dart';
import '../widgets/popup_button.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  CalendarWidgetState createState() => CalendarWidgetState();
}

class CalendarWidgetState extends State<CalendarWidget> {
  final DateRangePickerController _dateRangePickerController =
      DateRangePickerController();

  final CalendarController _calendarController = CalendarController();
  final HolidayController _holidayController = Get.find<HolidayController>();
  final DataSource _meetingDataSource = DataSource([]);

  StreamSubscription<int>? _close;
  StreamSubscription? _close1;
  StreamSubscription? _close2;
  var _refreshKey = const ValueKey(1);

  @override
  void initState() {
    _calendarController.displayDate = DateTime.now();
    _calendarController.selectedDate = DateTime.now();
    _dateRangePickerController.displayDate = _calendarController.displayDate;
    _dateRangePickerController.selectedDate =
        _dateRangePickerController.displayDate;
    super.initState();
    _close1 = _holidayController.updated.listen((p0) {
      setState(() {
        _refreshKey = ValueKey(_holidayController.updated.value);
      });
    });

    final homeController = Get.find<HomeController>();
    _close2 = homeController.getRxThemeMode().listen((value) {
      setState(() {
        _refreshKey = ValueKey(DateTime.now().millisecondsSinceEpoch);
      });
    });
  }

  @override
  void dispose() {
    _close?.cancel();
    _close1?.cancel();
    _close2?.cancel();
    _meetingDataSource.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainZone();
  }

  Widget _buildPickerCell(
      BuildContext context, DateRangePickerCellDetails cellDetails) {
    final theme = ui.FluentTheme.of(context);
    if (_dateRangePickerController.view == DateRangePickerView.month) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final isBefore = cellDetails.date.isBefore(today);
      final isToday = cellDetails.date.isAtSameMomentAs(today);
      final lunar = getLunarDayText(cellDetails.date);
      final holiday = _holidayController.findHolidayInfo(cellDetails.date);
      final dayType = holiday != null
          ? (holiday.dayType == DayType.vacation ? "休" : "班")
          : null;

      final showDate = _dateRangePickerController.selectedDate ??
          _dateRangePickerController.displayDate;

      final isSelectedToday =
          (showDate != null ? showDate.isSameDate(cellDetails.date) : false);

      Color? getColor() {
        return isToday
            ? (isSelectedToday ? Colors.white : theme.accentColor)
            : isSelectedToday
                ? Colors.white
                : theme.typography.body!.color;
      }

      return Container(
        width: cellDetails.bounds.width,
        height: cellDetails.bounds.height,
        alignment: Alignment.center,
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
                      style:
                          TextStyle(color: isBefore ? Colors.grey : getColor()),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        dayType ?? "",
                        style: TextStyle(
                            color: isBefore ? Colors.grey : Colors.redAccent,
                            fontSize: 8),
                      ),
                    ),
                  ],
                ),
                Text(
                  holiday?.name ?? lunar,
                  style: TextStyle(
                      height: 1,
                      color: isBefore ? Colors.grey : getColor(),
                      fontSize: 8),
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

  Widget _buildTopZone() {
    final theme = ui.FluentTheme.of(context);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 20.px, right: 20.px, top: 15.px),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: Localizations.override(
              context: context,
              locale: const Locale('zh', 'CN'),
              child: SfDateRangePicker(
                key: _refreshKey,
                cellBuilder: _buildPickerCell,
                backgroundColor: Colors.transparent,
                headerHeight: 0,
                headerStyle: DateRangePickerHeaderStyle(
                    textAlign: TextAlign.left,
                    textStyle:
                        TextStyle(color: theme.accentColor, fontSize: 12.0)),
                controller: _dateRangePickerController,
                showNavigationArrow: false,
                allowViewNavigation: true,
                onSelectionChanged: (value) {
                  _calendarController.selectedDate = value.value;
                  _calendarController.displayDate = value.value;
                  setState(() {});
                },
                selectionColor: theme.selectionColor,
                monthViewSettings: const DateRangePickerMonthViewSettings(
                    firstDayOfWeek: 7, dayFormat: 'E', viewHeaderHeight: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const formatStr = "MM-dd hh:mm";
  static final formatter = DateFormat(formatStr);

  Widget _buildMainZone() {
    final theme = ui.FluentTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(left: 10.px, right: 10.px, top: 10.px),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                  DateFormat.MMMd('zh-CN').format(
                      _dateRangePickerController.selectedDate ??
                          _dateRangePickerController.displayDate!),
                  style: TextStyle(
                      fontSize: 17, color: theme.typography.title!.color)),
              const Spacer(),
              ui.IconButton(
                  icon: Icon(
                    ui.FluentIcons.page_left,
                    color: theme.typography.body!.color!.withAlpha(100),
                    size: 20,
                  ),
                  onPressed: () {
                    _calendarController.backward?.call();
                    _dateRangePickerController.selectedDate =
                        _calendarController.displayDate;
                    _dateRangePickerController.displayDate =
                        _calendarController.displayDate;
                    setState(() {});
                  }),
              SizedBox(
                width: 8.px,
              ),
              SizedBox(
                height: 28.0,
                width: 70,
                child: MouseRegionBuilder(builder: (context, _) {
                  return ui.Button(
                      onPressed: () {
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        _dateRangePickerController.displayDate = today;
                        _dateRangePickerController.selectedDate = today;
                        _calendarController.selectedDate = today;
                        _calendarController.displayDate =
                            now.subtract(Duration(hours: now.hour > 1 ? 1 : 0));
                        setState(() {});
                      },
                      child: Text(
                        "今天",
                        style: theme.typography.caption,
                      ));
                }),
              ),
              SizedBox(
                width: 8.px,
              ),
              ui.IconButton(
                  icon: Icon(
                    ui.FluentIcons.page_right,
                    size: 20,
                    color: theme.typography.body!.color!.withAlpha(100),
                  ),
                  onPressed: () {
                    _calendarController.forward?.call();
                    _dateRangePickerController.selectedDate =
                        _calendarController.displayDate;
                    _dateRangePickerController.displayDate =
                        _calendarController.displayDate;
                    setState(() {});
                  }),
            ],
          ),
        ),
        _buildTopZone(),
        Expanded(
          child: Localizations.override(
            context: context,
            locale: const Locale('zh', 'CN'),
            child: SfCalendar(
              cellBorderColor: Colors.grey,
              todayHighlightColor: theme.accentColor,
              onViewChanged: (ViewChangedDetails details) async {},
              onSelectionChanged:
                  (CalendarSelectionDetails selectionDetails) {},
              controller: _calendarController,
              view: CalendarView.day,
              allowViewNavigation: false,
              viewNavigationMode: ViewNavigationMode.none,
              headerHeight: 0,
              dataSource: _meetingDataSource,
              appointmentBuilder: _getAppointmentUI,
              timeSlotViewSettings: const TimeSlotViewSettings(
                  minimumAppointmentDuration: Duration(minutes: 30),
                  timeInterval: Duration(minutes: 60),
                  timeIntervalHeight: 35,
                  timelineAppointmentHeight: 10,
                  dateFormat: 'd',
                  timeFormat: 'h a',
                  dayFormat: 'EEE',
                  timeRulerSize: 50,
                  timeTextStyle: TextStyle(fontSize: 12, color: Colors.grey)),
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
            ),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
      ],
    );
  }

  Widget _getAppointmentUI(
      BuildContext context, CalendarAppointmentDetails details) {
    final theme = ui.FluentTheme.of(context);
    final Appointment meeting = details.appointments.first;
    Widget widget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(3)),
        border: Border.all(color: meeting.color),
        color: meeting.color,
      ),
      child: Text(
        meeting.subject,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
        maxLines: 2,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
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
}
