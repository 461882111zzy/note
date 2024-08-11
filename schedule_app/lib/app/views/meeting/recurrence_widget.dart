///Dart imports
import 'dart:core';

import 'package:dailyflowy/app/views/utils.dart';
import 'package:fluent_ui/fluent_ui.dart' as ui;

///Package imports
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;

///calendar import
import 'package:syncfusion_flutter_calendar/calendar.dart';
// ignore: depend_on_referenced_packages

/// Dropdown list items for recurrenceType
List<String> _repeatOption = <String>[
  'Never',
  'Daily',
  'Weekly',
  'Monthly',
  'Yearly'
];

List<String> _repeatOptionStr = <String>['从不', '每日', '每周', '每月', '每年'];

/// Dropdown list items for day of week
List<String> _weekDay = <String>[
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

List<String> _weekDayStr = <String>['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

/// Dropdown list items for end range
List<String> _ends = <String>[
  'Never',
  'Count',
  'Until',
];

List<String> _endsStr = <String>[
  '从不',
  '次数',
  '直到',
];

/// Dropdown list items for months of year
List<String> _dayMonths = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

List<String> _dayMonthsStr = <String>[
  '一月',
  '二月',
  '三月',
  '四月',
  '五月',
  '六月',
  '七月',
  '八月',
  '九月',
  '十月',
  '十一月',
  '十二月'
];

/// Dropdown list items for week number of the month.
List<String> _daysPosition = <String>[
  'First',
  'Second',
  'Third',
  'Fourth',
  'Last'
];

List<String> _daysPositionStr = <String>['第一个', '第二个', '第三个', '第四个', '最后一个'];

typedef GetRecrrenceRule = String? Function(DateTime appStart, DateTime appEnd);

class RecurrenceController {
  GetRecrrenceRule? getRecrrenceRule;

  String? recrrenceRule(DateTime appStart, DateTime appEnd) {
    return getRecrrenceRule?.call(appStart, appEnd);
  }
}

/// Builds the appointment editor with all the required elements in a pop-up
/// based on the tapped calendar element.
class RecurrenceEditor extends StatefulWidget {
  /// Holds the information of appointments
  const RecurrenceEditor(this.startDate, this.recurrenceRule, this.controller,
      {super.key});

  final String? recurrenceRule;

  final RecurrenceController controller;

  final DateTime startDate;

  @override
  RecurrenceEditorState createState() => RecurrenceEditorState();
}

class RecurrenceEditorState extends State<RecurrenceEditor> {
  String _selectedRecurrenceType = '',
      _selectedRecurrenceRange = '',
      _ruleType = '';
  int? _count, _interval, _month, _week, _lastDay;
  int _dayOfWeek = 0, _weekNumber = 0, _dayOfMonth = 0;
  DateTime? _endDate;
  RecurrenceProperties? _recurrenceProperties;
  List<WeekDays>? _days;
  bool _monthDayRadio = false, _weekDayRadio = false;

  @override
  void initState() {
    widget.controller.getRecrrenceRule = _transToRecurrence;
    _updateAppointmentProperties();
    super.initState();
  }

  @override
  void didUpdateWidget(RecurrenceEditor oldWidget) {
    widget.controller.getRecrrenceRule = _transToRecurrence;
    if (widget.recurrenceRule != oldWidget.recurrenceRule ||
        widget.startDate != oldWidget.startDate) {
      _updateAppointmentProperties();
    }

    super.didUpdateWidget(oldWidget);
  }

  /// Updates the required editor's default field
  void _updateAppointmentProperties() {
    _endDate = widget.startDate.add(const Duration(days: 30));
    _month = widget.startDate.month;
    _dayOfMonth = widget.startDate.day;
    _weekNumber = _getWeekNumber(widget.startDate);
    _dayOfWeek = widget.startDate.weekday;

    _webInitialWeekdays(_dayOfWeek);

    _recurrenceProperties ??=
        widget.recurrenceRule != null && widget.recurrenceRule!.isNotEmpty
            ? SfCalendar.parseRRule(
                widget.recurrenceRule!
                    .replaceAll('BYMONTHDAY=0', 'BYMONTHDAY=1')
                    .replaceAll('BYMONTH=0', 'BYMONTH=1'),
                widget.startDate)
            : null;
    _recurrenceProperties == null
        ? _neverRule()
        : _updateWebRecurrenceProperties();
  }

  String get weekNumberText =>
      _daysPosition[_weekNumber == -1 ? 4 : _weekNumber - 1];

  String get dayOfWeekText => _weekDay[_dayOfWeek - 1];

  String get monthName => _dayMonths[_month! - 1];

  void _updateWebRecurrenceProperties() {
    final recurrenceType = _recurrenceProperties!.recurrenceType;
    _week = _recurrenceProperties!.week;
    _weekNumber = _recurrenceProperties!.week == 0
        ? _weekNumber
        : _recurrenceProperties!.week;
    _lastDay = _recurrenceProperties!.dayOfMonth;
    if (_lastDay != -1) {
      _dayOfMonth = _recurrenceProperties!.dayOfMonth <= 1
          ? widget.startDate.day
          : _recurrenceProperties!.dayOfMonth;
    }
    switch (recurrenceType) {
      case RecurrenceType.daily:
        _dailyRule();
        break;
      case RecurrenceType.weekly:
        _days = _recurrenceProperties!.weekDays;
        _weeklyRule();
        break;
      case RecurrenceType.monthly:
        _monthlyRule();
        break;
      case RecurrenceType.yearly:
        _month = _recurrenceProperties!.month;
        _yearlyRule();
        break;
    }
    final recurrenceRange = _recurrenceProperties!.recurrenceRange;
    switch (recurrenceRange) {
      case RecurrenceRange.noEndDate:
        _noEndDateRange();
        break;
      case RecurrenceRange.endDate:
        _endDateRange();
        break;
      case RecurrenceRange.count:
        _countRange();
        break;
    }
  }

  String? _transToRecurrence(DateTime appStart, DateTime appEnd) {
    if (_recurrenceProperties == null) {
      return null;
    }
    return SfCalendar.generateRRule(_recurrenceProperties!, appStart, appEnd);
  }

  void _neverRule() {
    setState(() {
      _recurrenceProperties = null;
      _selectedRecurrenceType = 'Never';
      _selectedRecurrenceRange = 'Never';
      _ruleType = '';
    });
  }

  void _dailyRule() {
    setState(() {
      if (_recurrenceProperties == null) {
        _recurrenceProperties =
            RecurrenceProperties(startDate: widget.startDate);
        _interval = 1;
      } else {
        _interval = _recurrenceProperties!.interval;
      }
      _recurrenceProperties!.recurrenceType = RecurrenceType.daily;
      _ruleType = '天';
      _selectedRecurrenceType = 'Daily';
    });
  }

  void _weeklyRule() {
    setState(() {
      if (_recurrenceProperties == null) {
        _recurrenceProperties =
            RecurrenceProperties(startDate: widget.startDate);
        _interval = 1;
      } else {
        _interval = _recurrenceProperties!.interval;
      }
      _recurrenceProperties!.recurrenceType = RecurrenceType.weekly;
      _selectedRecurrenceType = 'Weekly';
      _ruleType = '周的';
      _recurrenceProperties!.weekDays = _days!;
    });
  }

  void _monthlyRule() {
    setState(() {
      if (_recurrenceProperties == null) {
        _recurrenceProperties =
            RecurrenceProperties(startDate: widget.startDate);
        _monthDayIcon();
        _interval = 1;
      } else {
        _dayOfWeek = _recurrenceProperties!.dayOfWeek;
        _interval = _recurrenceProperties!.interval;
        if (_lastDay != null && _lastDay == -1) {
          _monthLastDayIcon();
        } else if (_week != null && _week != 0) {
          _monthWeekIcon();
        } else {
          _monthDayIcon();
        }
      }
      _recurrenceProperties!.recurrenceType = RecurrenceType.monthly;
      _selectedRecurrenceType = 'Monthly';
      _ruleType = '月';
    });
  }

  void _yearlyRule() {
    setState(() {
      if (_recurrenceProperties == null) {
        _recurrenceProperties =
            RecurrenceProperties(startDate: widget.startDate);
        _monthDayIcon();
        _interval = 1;
      } else {
        _dayOfWeek = _recurrenceProperties!.dayOfWeek;
        _interval = _recurrenceProperties!.interval;
        if (_lastDay != null && _lastDay == -1) {
          _monthLastDayIcon();
        } else if (_week != null && _week != 0) {
          _monthWeekIcon();
        } else {
          _monthDayIcon();
        }
      }
      _recurrenceProperties!.recurrenceType = RecurrenceType.yearly;
      _selectedRecurrenceType = 'Yearly';
      _ruleType = '年';
      _recurrenceProperties!.month = _month!;
    });
  }

  void _noEndDateRange() {
    _recurrenceProperties!.recurrenceRange = RecurrenceRange.noEndDate;
    _selectedRecurrenceRange = 'Never';
  }

  void _endDateRange() {
    _recurrenceProperties!.recurrenceRange = RecurrenceRange.endDate;
    _endDate = _recurrenceProperties!.endDate ??
        widget.startDate.add(const Duration(days: 30));
    _selectedRecurrenceRange = 'Until';
    _recurrenceProperties!.endDate = _endDate!;
  }

  void _countRange() {
    _recurrenceProperties!.recurrenceRange = RecurrenceRange.count;
    _count = _recurrenceProperties!.recurrenceCount == 0
        ? 10
        : _recurrenceProperties!.recurrenceCount;
    _selectedRecurrenceRange = 'Count';
    _recurrenceProperties!.recurrenceCount = _count!;
  }

  int _getWeekNumber(DateTime startDate) {
    int weekOfMonth;
    weekOfMonth = (startDate.day / 7).ceil();
    if (weekOfMonth == 5) {
      return -1;
    }
    return weekOfMonth;
  }

  void _monthWeekIcon() {
    setState(() {
      _recurrenceProperties!.week = _weekNumber;
      _recurrenceProperties!.dayOfWeek = _dayOfWeek;
      _monthDayRadio = false;
      _weekDayRadio = true;
    });
  }

  void _monthDayIcon() {
    setState(() {
      _recurrenceProperties!.dayOfWeek = 0;
      _recurrenceProperties!.week = 0;
      _recurrenceProperties!.dayOfMonth = _dayOfMonth;
      _monthDayRadio = true;
      _weekDayRadio = false;
    });
  }

  void _monthLastDayIcon() {
    setState(() {
      _recurrenceProperties!.dayOfWeek = 0;
      _recurrenceProperties!.week = 0;
      _recurrenceProperties!.dayOfMonth = -1;
      _monthDayRadio = false;
      _weekDayRadio = true;
    });
  }

  void _selectWeekDays(WeekDays day) {
    switch (day) {
      case WeekDays.sunday:
        if (_days!.contains(WeekDays.sunday) && _days!.length > 1) {
          _days!.remove(WeekDays.sunday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.sunday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.monday:
        if (_days!.contains(WeekDays.monday) && _days!.length > 1) {
          _days!.remove(WeekDays.monday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.monday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.tuesday:
        if (_days!.contains(WeekDays.tuesday) && _days!.length > 1) {
          _days!.remove(WeekDays.tuesday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.tuesday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.wednesday:
        if (_days!.contains(WeekDays.wednesday) && _days!.length > 1) {
          _days!.remove(WeekDays.wednesday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.wednesday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.thursday:
        if (_days!.contains(WeekDays.thursday) && _days!.length > 1) {
          _days!.remove(WeekDays.thursday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.thursday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.friday:
        if (_days!.contains(WeekDays.friday) && _days!.length > 1) {
          _days!.remove(WeekDays.friday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.friday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.saturday:
        if (_days!.contains(WeekDays.saturday) && _days!.length > 1) {
          _days!.remove(WeekDays.saturday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.saturday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
    }

    setState(() {});
  }

  void _webInitialWeekdays(int day) {
    switch (day) {
      case DateTime.monday:
        _days = <WeekDays>[WeekDays.monday];
        break;
      case DateTime.tuesday:
        _days = <WeekDays>[WeekDays.tuesday];
        break;
      case DateTime.wednesday:
        _days = <WeekDays>[WeekDays.wednesday];
        break;
      case DateTime.thursday:
        _days = <WeekDays>[WeekDays.thursday];
        break;
      case DateTime.friday:
        _days = <WeekDays>[WeekDays.friday];
        break;
      case DateTime.saturday:
        _days = <WeekDays>[WeekDays.saturday];
        break;
      case DateTime.sunday:
        _days = <WeekDays>[WeekDays.sunday];
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          '重复',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(
          height: 4,
        ),
        Row(
          children: [
            _buildRepeatTypeSelector(),
            const SizedBox(
              width: 32,
            ),
            _buildRepeatIntervaltSelector(),
          ],
        ),
        if (_selectedRecurrenceType == 'Weekly') _buildWeekSelector(),
        if (_selectedRecurrenceType == 'Monthly' ||
            _selectedRecurrenceType == 'Yearly')
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDayOfMonthRepeatSetting(),
              const SizedBox(
                width: 30,
              ),
              _buildWeekOfMonthRepeatSelector(),
            ],
          ).marginOnly(top: 6),
        const SizedBox(
          height: 4,
        ),
        _buildRepeatEndSetting(),
      ],
    );
  }

  Widget _buildWeekOfMonthRepeatSelector() {
    return Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
      ui.RadioButton(
          checked: _weekDayRadio,
          onChanged: (_) {
            _monthWeekIcon();
          }),
      const SizedBox(
        width: 10,
      ),
      const Text('在'),
      const SizedBox(
        width: 10,
      ),
      Row(
        children: <Widget>[
          SizedBox(
            width: 100,
            child: ui.ComboBox<int>(
                isExpanded: true,
                value: _daysPosition.indexOf(weekNumberText),
                items: _buildRepeatItems(_daysPositionStr),
                onChanged: (int? value) {
                  setState(() {
                    updateWeekNumber(value!);
                  });
                }),
          ),
          const SizedBox(
            width: 10,
          ),
          SizedBox(
            width: 85,
            child: ui.ComboBox<int>(
                isExpanded: true,
                value: _dayOfWeek - 1,
                items: _buildRepeatItems(
                    ['周一', '周二', '周三', '周四', '周五', '周六', '周日']),
                onChanged: (int? value) {
                  setState(() {
                    updateDayOfWeek(value!);
                  });
                }),
          ),
        ],
      ),
    ]);
  }

  Widget _buildRepeatEndSetting() {
    return Visibility(
        visible: _selectedRecurrenceType != 'Never',
        child: Container(
          padding: const EdgeInsets.only(left: 0, top: 4, bottom: 2),
          margin: const EdgeInsets.only(left: 0),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  '结束',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(
                  width: 10.px,
                ),
                ui.SizedBox(
                  width: 94,
                  child: ui.ComboBox<int>(
                      isExpanded: true,
                      value: _ends.indexOf(_selectedRecurrenceRange),
                      items: _buildRepeatItems(_endsStr),
                      onChanged: (int? value) {
                        setState(() {
                          if (value == 0) {
                            _noEndDateRange();
                          } else if (value == 1) {
                            _countRange();
                          } else if (value == 2) {
                            _endDateRange();
                          }
                        });
                      }),
                ),
                if (_selectedRecurrenceRange == 'Count')
                  Padding(
                      padding: const EdgeInsets.only(left: 9),
                      child: ui.SizedBox(
                        width: 120,
                        child: ui.NumberBox(
                            value: _count,
                            min: 1,
                            max: 999,
                            clearButton: false,
                            mode: ui.SpinButtonPlacementMode.inline,
                            onChanged: (int? value) {
                              updateEndCount(value);
                            }),
                      )),
                if (_selectedRecurrenceRange == 'Until')
                  Container(
                    width: 130,
                    padding: const EdgeInsets.only(left: 9),
                    child: ui.Row(
                      children: [
                        ui.Expanded(
                          child: Text(
                            DateFormat('MM-dd-yyyy').format(_endDate!),
                          ),
                        ),
                        ui.IconButton(
                          onPressed: () async {
                            final selectedDate = await showDatePickerEx(context,
                                initDate: _endDate);
                            setState(() {
                              if (selectedDate != null) {
                                _endDate = selectedDate;
                                _recurrenceProperties!.endDate = _endDate!;
                              }
                            });
                          },
                          icon: const Icon(
                            Icons.date_range,
                            size: 20,
                          ),
                        )
                      ],
                    ),
                  ),
              ]),
        ));
  }

  void updateEndCount(int? value) {
    if (value != null) {
      _count = value;
      _recurrenceProperties!.recurrenceRange = RecurrenceRange.count;
      _selectedRecurrenceRange = 'Count';
      _recurrenceProperties!.recurrenceCount = _count!;
    } else {
      _noEndDateRange();
    }
  }

  Widget _buildDayOfMonthRepeatSetting() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            ui.RadioButton(
                checked: _monthDayRadio,
                onChanged: (_) {
                  _monthDayIcon();
                }),
            const SizedBox(
              width: 10,
            ),
            const Text(
              '在第',
            ),
            const SizedBox(
              width: 10,
            ),
            ui.SizedBox(
              child: ui.ComboBox<int>(
                items: List.generate(31, (index) {
                  return ui.ComboBoxItem<int>(
                      value: index, child: Text('${index + 1}'));
                }),
                value: _dayOfMonth - 1,
                onChanged: (int? value) {
                  updateDayOfMonth(value);
                },
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const Text(
              '天',
            ),
          ]),
        ]);
  }

  void updateDayOfMonth(int? value) {
    if (value != null) {
      _dayOfMonth = value + 1;
    } else {
      _dayOfMonth = widget.startDate.day;
    }

    if (_dayOfMonth <= 1) {
      _dayOfMonth = widget.startDate.day;
    }

    _recurrenceProperties!.dayOfWeek = 0;
    _recurrenceProperties!.week = 0;
    _recurrenceProperties!.dayOfMonth = _dayOfMonth;

    _monthDayRadio = true;
    _weekDayRadio = false;

    setState(() {});
  }

  Widget _buildRepeatIntervaltSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildRepeatIntervalInput(),
        Text(_ruleType),
        Visibility(
          visible: _selectedRecurrenceType == 'Yearly',
          child: Padding(
              padding: const EdgeInsets.only(left: 0, right: 5),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      '的',
                    ),
                    const ui.SizedBox(
                      width: 18,
                    ),
                    ui.SizedBox(
                      width: 85,
                      child: ui.ComboBox<int>(
                        isExpanded: true,
                        value: _dayMonths.indexOf(monthName),
                        items: _buildRepeatItems(_dayMonthsStr),
                        onChanged: (int? value) {
                          setState(() {
                            updateMonth(value!, _recurrenceProperties);
                          });
                        },
                      ),
                    ),
                  ])),
        ),
      ],
    );
  }

  List<ui.ComboBoxItem<int>> _buildRepeatItems(List<String> items) {
    final theme = ui.FluentTheme.of(context);
    return items
        .map((e) => ui.ComboBoxItem<int>(
              value: items.indexOf(e),
              child: Text(
                e,
                style: TextStyle(
                    fontSize: 13.0, color: theme.typography.subtitle!.color),
              ),
            ))
        .toList();
  }

  Widget _buildRepeatTypeSelector() {
    return SizedBox(
      width: 153,
      child: ui.ComboBox<int>(
        focusColor: Colors.transparent,
        isExpanded: true,
        value: _repeatOption.indexOf(_selectedRecurrenceType),
        items: _buildRepeatItems(_repeatOptionStr),
        onChanged: (int? value) {
          if (value == 4) {
            _yearlyRule();
          } else if (value == 3) {
            _monthlyRule();
          } else if (value == 2) {
            _weeklyRule();
          } else if (value == 1) {
            _dailyRule();
          } else if (value == 0) {
            _neverRule();
          }
        },
      ),
    );
  }

  Widget _buildRepeatIntervalInput() {
    return Visibility(
      visible: _selectedRecurrenceType != 'Never',
      child: Padding(
        padding: const EdgeInsets.only(left: 0, right: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text('每'),
            ui.SizedBox(width: 52.px),
            ui.ComboBox<int>(
              value: _interval,
              items: [1, 2, 3, 4, 5].map((e) {
                return ui.ComboBoxItem<int>(
                  value: e,
                  child: Text('$e'),
                );
              }).toList(),
              onChanged: (int? value) {
                setState(() {
                  if (value != null) {
                    _interval = value;
                    _recurrenceProperties!.interval = _interval!;
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void updateMonth(int value, RecurrenceProperties? recurrenceProperties) {
    setState(() {
      recurrenceProperties?.month = value + 1;
      _month = value + 1;
    });
  }

  void updateWeekNumber(int value) {
    const weekNumberMap = {
      0: 1,
      1: 2,
      2: 3,
      3: 4,
      4: -1,
    };

    // 检查 value 是否在映射中
    if (weekNumberMap.containsKey(value)) {
      _weekNumber = weekNumberMap[value]!;
    } else {
      // 如果 value 不在映射中，抛出异常或者设置错误信息
      throw ArgumentError('Invalid value for week number: $value');
    }
    _recurrenceProperties!.week = _weekNumber;
    _monthWeekIcon();

    setState(() {});
  }

  Widget _buildWeekSelector() {
    List<Widget> buildWeekDaysButtons() {
      List<Widget> buttons = [];
      for (var i = 0; i < WeekDays.values.length; i++) {
        buttons.add(ui.ToggleButton(
            checked: _days!.contains(WeekDays.values[i]),
            onChanged: (value) {
              _selectWeekDays(WeekDays.values[i]);
            },
            child: Text(
              _weekDayStr[i],
              style: const ui.TextStyle(
                fontSize: 12,
              ),
            )));
      }
      return buttons;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 3.0,
        runSpacing: 10.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: buildWeekDaysButtons(),
      ),
    );
  }

  void updateDayOfWeek(int i) {
    _dayOfWeek = i + 1;
    _recurrenceProperties?.dayOfWeek = _dayOfWeek;
    setState(() {});
    _monthWeekIcon();
  }
}
