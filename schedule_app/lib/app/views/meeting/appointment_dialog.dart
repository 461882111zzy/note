import 'package:dailyflowy/app/controllers/calendar_controller.dart'
    as meeting_controller;
import 'package:dailyflowy/app/data/meeting.dart';
import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:date_format/date_format.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:get/get.dart';
import '../time_picker_ex.dart';
// ignore: implementation_imports
import 'package:fluent_ui/src/controls/form/pickers/pickers.dart';

import 'recurrence_widget.dart';

Future<Meeting?> editAppointmentDialog(BuildContext context,
    {required Meeting? meeting}) async {
  final newMeeting = await showDialog<Meeting>(
      context: context,
      dismissWithEsc: false,
      barrierColor: material.Colors.black12,
      builder: (context) {
        return _NewAppointmentDialog(
          meeting: meeting,
        );
      });

  if (newMeeting == null) {
    return null;
  }

  final meeting_controller.CalendarController calendarController = Get.find();
  if (meeting == null) {
    calendarController.addMeeting(newMeeting);
  } else {
    calendarController.updateMeeting(newMeeting);
  }

  return newMeeting;
}

class _NewAppointmentDialog extends StatefulWidget {
  final Meeting? meeting;
  const _NewAppointmentDialog({
    this.meeting,
  });

  @override
  State<StatefulWidget> createState() {
    return _NewAppointmentDialogState();
  }
}

class _NewAppointmentDialogState extends State<_NewAppointmentDialog> {
  late bool _isAllDay;
  late int _durationSelected;

  final RecurrenceController _recurrenceController = RecurrenceController();
  final _durationSelects = ['30分钟', '1小时', '2小时', '3小时', '自定义结束时间'];
  final List<num> _durationItems = [0.5, 1, 2, 3];

  late TextEditingController _title;
  late TextEditingController _desc;
  final FocusNode _focusNode = FocusNode();

  late DateTime _startDate;
  late material.TimeOfDay _startTime;
  DateTime? _endDate;
  material.TimeOfDay? _endTime;

  @override
  void initState() {
    _isAllDay = widget.meeting?.isAllDay ?? false;
    _durationSelected = 1;
    _title = TextEditingController();
    _title.text = widget.meeting?.title ?? '';
    _desc = TextEditingController();
    _desc.text = widget.meeting?.notes ?? '';

    if (widget.meeting?.from != null) {
      _startDate = DateTime(widget.meeting!.from!.year,
          widget.meeting!.from!.month, widget.meeting!.from!.day);
      _startTime = material.TimeOfDay(
          hour: widget.meeting!.from!.hour,
          minute: widget.meeting!.from!.minute);
      if (_startTime.hour == 0 && _startTime.minute == 0) {
        _startTime = material.TimeOfDay.now();
      }
    } else {
      _startDate = DateTime.now();
      _startTime = material.TimeOfDay.now();
    }

    if (widget.meeting?.to != null) {
      _endDate = DateTime(widget.meeting!.to!.year, widget.meeting!.to!.month,
          widget.meeting!.to!.day);
      _endTime = material.TimeOfDay(
          hour: widget.meeting!.to!.hour, minute: widget.meeting!.to!.minute);
    }

    _initDurationSelect();

    super.initState();
  }

  void _initDurationSelect() {
    // 根据_startTime, _endTime,计算时长，如果是0.5h, 1h，2h，3h, 设置_durationSelected 为 0， 1， 2， 3，否则，设置为 4
    if (_endTime != null && _endDate != null) {
      final tmpEnd = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      final tmpStart = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final duration = tmpEnd.difference(tmpStart);
      if (duration.inMinutes == 30) {
        _durationSelected = 0;
      } else if (duration.inMinutes == 60) {
        _durationSelected = 1;
      } else if (duration.inMinutes == 120) {
        _durationSelected = 2;
      } else if (duration.inMinutes == 180) {
        _durationSelected = 3;
      } else {
        _durationSelected = 4;
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void setStartDate(DateTime date) {
    if (date != _startDate) {
      setState(() {
        _startDate = date;
      });
    }
  }

  void setStartTime(material.TimeOfDay time) {
    _startTime = time;
  }

  void setEndDate(DateTime date) {
    _endDate = date;
  }

  void setEndTime(material.TimeOfDay time) {
    _endTime = time;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return material.Dialog(
      child: FlyoutContent(
        child: Container(
          width: 660.px,
          //   height: 626.px,
          padding: EdgeInsets.only(top: 24.px, left: 33.px, right: 33.px),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 54.px,
                child: TextBox(
                  controller: _title,
                  scrollPadding: EdgeInsets.zero,
                  style: TextStyle(
                      color: theme.typography.subtitle!.color, fontSize: 16),
                  minLines: 1,
                  maxLines: 1,
                  maxLength: 40,
                  cursorHeight: 18,
                  showCursor: true,
                  cursorWidth: 1,
                  onChanged: (value) {
                    setState(() {});
                  },
                  cursorColor: theme.accentColor,
                  placeholder: '日程，或会议',
                ),
              ),
              SizedBox(
                height: 37.px,
              ),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '开始',
                    style: TextStyle(fontSize: 14),
                  )),
              SizedBox(
                height: 4.px,
              ),
              Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44.px,
                        child: DateSelectWidget(
                          setValue: setStartDate,
                          init: _startDate,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 44.px,
                        child: TimePickerEx(
                            onChanged: (value) {
                              setState(() {
                                setStartTime(value);
                              });
                            },
                            selected: _startTime),
                      ),
                    ),
                    SizedBox(
                      width: 19.px,
                    ),
                    const Text(
                      '全天',
                      style: TextStyle(fontSize: 14),
                    ),
                    Checkbox(
                        checked: _isAllDay,
                        onChanged: (value) {
                          setState(() {
                            _isAllDay = value!;
                          });
                        }).marginOnly(left: 8, right: 8),
                  ]),
              SizedBox(
                height: 20.px,
              ),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '时长',
                    style: TextStyle(fontSize: 14),
                  )),
              SizedBox(
                height: 4.px,
              ),
              _durationSelected < 4
                  ? Align(
                      alignment: Alignment.centerLeft, child: _buildDuration())
                  : Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44.px,
                            child: DateSelectWidget(
                              setValue: setEndDate,
                              init: _endDate,
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 44.px,
                            child: TimePickerEx(
                                onChanged: (value) {
                                  setState(() {
                                    setEndTime(value);
                                  });
                                },
                                selected: _endTime),
                          ),
                        ),
                      ],
                    ).marginOnly(right: 105.px),
              SizedBox(
                height: 20.px,
              ),
              RecurrenceEditor(_startDate, widget.meeting?.recurrenceRule,
                  _recurrenceController),
              SizedBox(
                height: 20.px,
              ),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '描述',
                    style: TextStyle(fontSize: 14),
                  )),
              SizedBox(
                height: 4.px,
              ),
              SizedBox(
                width: double.infinity,
                height: 100.px,
                child: TextBox(
                  controller: _desc,
                  style: TextStyle(
                      fontSize: 14.0, color: theme.typography.subtitle!.color),
                  minLines: 5,
                  maxLines: 5,
                  maxLength: 100,
                  cursorHeight: 18,
                  showCursor: true,
                  textAlignVertical: TextAlignVertical.top,
                  cursorWidth: 1,
                  textAlign: TextAlign.left,
                  cursorColor: theme.accentColor,
                  // decoration: BoxDecoration(
                  //     color: const Color.fromRGBO(237, 237, 237, 0.3),
                  //     border: Border.all(
                  //       color: const Color.fromRGBO(127, 135, 160, 0.3),
                  //     ),
                  //     borderRadius: BorderRadius.circular(5)),
                  placeholder: '请输入内容',
                ),
              ),
              SizedBox(
                height: 30.px,
              ),
              Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    width: 120.px,
                    child: MouseRegionBuilder(builder: (context, _) {
                      return Button(
                          onPressed: () {
                            FocusScope.of(context).requestFocus(_focusNode);
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            '取消',
                            style: TextStyle(color: theme.accentColor.normal),
                          ));
                    }),
                  ),
                  SizedBox(
                    width: 20.px,
                  ),
                  SizedBox(
                    width: 120.px,
                    child: MouseRegionBuilder(builder: (context, _) {
                      return FilledButton(
                        onPressed: _title.text.isNotEmpty
                            ? () {
                                FocusScope.of(context).requestFocus(_focusNode);
                                _buildMeeting(context);
                              }
                            : null,
                        child: const Text(
                          '确定',
                        ),
                      );
                    }),
                  )
                ],
              ),
              SizedBox(
                height: 15.px,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _buildMeeting(BuildContext context) {
    _updateEndDateTime();
    if (_endDate == null || _endTime == null) {
      return;
    }

    final from = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final to = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    final recurrence = _recurrenceController.recrrenceRule(from, to);
    print(recurrence);

    // ignore: prefer_typing_uninitialized_variables
    var meeting = widget.meeting;
    if (widget.meeting == null) {
      meeting = Meeting()
        ..title = _title.text
        ..from = from
        ..to = to
        ..isAllDay = _isAllDay
        ..recurrenceRule = recurrence
        ..notes = _desc.text;
    } else {
      meeting
        ?..title = _title.text
        ..from = from
        ..to = to
        ..isAllDay = _isAllDay
        ..recurrenceRule = recurrence
        ..notes = _desc.text;
    }

    Navigator.of(context).pop(meeting);
    return;
  }

  Widget _buildDuration() {
    return ComboBox(
      value: _durationSelected,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      onChanged: (v) {
        setState(() {
          _durationSelected = v!;
        });

        if (_durationSelected < 4) {
          _updateEndDateTime();
        }
      },
      items: _buildDurationItems(),
    );
  }

  void _updateEndDateTime() {
    if (_durationSelected > 3) {
      return;
    }
    final from = DateTime(_startDate.year, _startDate.month, _startDate.day,
        _startTime.hour, _startTime.minute);
    final to = from.add(Duration(
        hours: _durationSelected > 0
            ? _durationItems[_durationSelected] as int
            : 0,
        minutes: _durationSelected == 0 ? 30 : 0));
    setEndDate(to);
    setEndTime(material.TimeOfDay(hour: to.hour, minute: to.minute));
  }

  List<ComboBoxItem<int>> _buildDurationItems() {
    final theme = FluentTheme.of(context);
    return _durationSelects
        .map((e) => ComboBoxItem<int>(
              value: _durationSelects.indexOf(e),
              child: Text(
                e,
                style: TextStyle(
                    fontSize: 13.0, color: theme.typography.subtitle!.color),
              ),
            ))
        .toList();
  }
}

String _getDateString(DateTime time) {
  return formatDate(time, [
    mm,
    '-',
    dd,
    ' ',
    D,
  ]);
}

class DateSelectWidget extends StatefulWidget {
  final void Function(DateTime date) setValue;
  final DateTime? init;

  const DateSelectWidget(
      {super.key, required this.setValue, required this.init});

  @override
  State<StatefulWidget> createState() {
    return _DateSelectState();
  }
}

class _DateSelectState extends State<DateSelectWidget> {
  late DateTime _date;

  @override
  void initState() {
    _date = widget.init ?? DateTime.now();
    widget.setValue(_date);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return HoverButton(
        onPressed: () async {
          var selected = await showDatePickerEx(context, initDate: _date);
          _date = selected ?? _date;
          widget.setValue(_date);

          setState(() {});
        },
        cursor: SystemMouseCursors.click,
        builder: (context, states) {
          return FocusBorder(
              focused: states.isFocused,
              child: AnimatedContainer(
                  duration: theme.fastAnimationDuration,
                  curve: theme.animationCurve,
                  height: kPickerHeight,
                  decoration: kPickerDecorationBuilder(context, states),
                  child: DefaultTextStyle.merge(
                      style: TextStyle(
                          color: theme.resources.textFillColorSecondary),
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 11.px),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromARGB(255, 173, 173, 175),
                                width: 0.5,
                              ),
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(3),
                                  bottomLeft: Radius.circular(3))),
                          child: Center(
                            child: Row(
                              children: [
                                Text(
                                  _getDateString(_date),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 16.px,
                                      height: 1.0,
                                      color: theme.typography.subtitle!.color),
                                ),
                                const Spacer(),
                                const Icon(
                                  material.Icons.calendar_today_outlined,
                                  size: 15,
                                )
                              ],
                            ),
                          )))));
        });
  }
}
