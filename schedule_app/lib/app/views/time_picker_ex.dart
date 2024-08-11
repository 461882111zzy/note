// ignore_for_file: implementation_imports

import 'package:dailyflowy/app/views/utils.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/src/controls/form/pickers/pickers.dart';
import 'package:fluent_ui/src/intl_script_locale_apply_mixin.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

String _formatHour(int hour, String locale) {
  return DateFormat.H(locale).format(DateTime(
    0, // year
    0, // month
    0, // day
    hour,
  ));
}

String _formatMinute(int minute, String locale) {
  return DateFormat.m(locale).format(DateTime(
    0, // year
    0, // month
    0, // day
    0, // hour,
    minute,
  ));
}

/// The time picker gives you a standardized way to let users pick a time value
/// using touch, mouse, or keyboard input.
///
/// ![TimePicker Preview](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/controls-timepicker-expand.gif)
///
/// See also:
///
///  * [DatePicker], which gives you a standardized way to let users pick a
///    localized date value
///  * <https://docs.microsoft.com/en-us/windows/apps/design/controls/time-picker>
class TimePickerEx extends StatefulWidget {
  /// Creates a time picker.
  const TimePickerEx({
    super.key,
    required this.selected,
    this.onChanged,
    this.onCancel,
    this.hourFormat = HourFormat.HH,
    this.header,
    this.headerStyle,
    this.contentPadding = kPickerContentPadding,
    this.popupHeight = kPickerPopupHeight,
    this.focusNode,
    this.autofocus = false,
    this.minuteIncrement = 15,
    this.locale,
  });

  /// The current date selected date.
  ///
  /// If null, no date is going to be shown.
  final material.TimeOfDay? selected;

  /// Whenever the current selected date is changed by the user.
  ///
  /// If null, the picker is considered disabled
  final ValueChanged<material.TimeOfDay>? onChanged;

  /// Whenever the user cancels the date change.
  final VoidCallback? onCancel;

  /// The clock system to use
  final HourFormat hourFormat;

  /// The content of the header
  final String? header;

  /// The style of the [header]
  final TextStyle? headerStyle;

  /// The padding of the picker fields. Defaults to [kPickerContentPadding]
  final EdgeInsetsGeometry contentPadding;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// The height of the popup.
  ///
  /// Defaults to [kPickerPopupHeight]
  final double popupHeight;

  /// The value that indicates the time increments shown in the minute picker.
  /// For example, 15 specifies that the TimePicker minute control displays
  /// only the choices 00, 15, 30, 45.
  ///
  /// ![15 minute increment preview](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/date-time/time-picker-minute-increment.png)
  ///
  /// Defaults to 1
  final int minuteIncrement;

  /// The locale used to format the month name.
  ///
  /// If null, the system locale will be used.
  final Locale? locale;

  bool get use24Format => [HourFormat.HH, HourFormat.H].contains(hourFormat);

  @override
  State<TimePickerEx> createState() => _TimePickerStateEx();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<material.TimeOfDay>('selected', selected,
          ifNull: 'now'))
      ..add(EnumProperty<HourFormat>(
        'hourFormat',
        hourFormat,
        defaultValue: HourFormat.h,
      ))
      ..add(DiagnosticsProperty(
        'contentPadding',
        contentPadding,
        defaultValue: kPickerContentPadding,
      ))
      ..add(ObjectFlagProperty.has('focusNode', focusNode))
      ..add(FlagProperty(
        'autofocus',
        value: autofocus,
        ifFalse: 'manual focus',
        defaultValue: false,
      ))
      ..add(DoubleProperty('popupHeight', popupHeight,
          defaultValue: kPickerPopupHeight))
      ..add(IntProperty('minuteIncrement', minuteIncrement, defaultValue: 1));
  }
}

int getClosestMinute(List<int> possibleMinutes, int goal) {
  return possibleMinutes
      .reduce(
        (prev, curr) => (curr - goal).abs() < (prev - goal).abs() ? curr : prev,
      )
      .clamp(0, 59);
}

class _TimePickerStateEx extends State<TimePickerEx>
    with IntlScriptLocaleApplyMixin {
  late material.TimeOfDay time;

  final GlobalKey _buttonKey = GlobalKey(debugLabel: 'Time Picker button key');

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _amPmController;

  bool am = true;

  @override
  void initState() {
    time = widget.selected ?? material.TimeOfDay.now();
    initControllers();
    super.initState();
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _amPmController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TimePickerEx oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != time) {
      time = widget.selected ?? material.TimeOfDay.now();
      _hourController.jumpToItem(() {
        var hour = time.hour - 1;
        if (!widget.use24Format) {
          hour -= 12;
        }
        return hour;
      }());
      _minuteController.jumpToItem(calcMinuteItem(time.minute));
      _amPmController.jumpToItem(_isPm ? 1 : 0);
    }
  }

  int calcMinuteItem(int minute) {
    final possibleMinutes = List.generate(
      60 ~/ widget.minuteIncrement,
      (index) => index * widget.minuteIncrement,
    );

    if (!possibleMinutes.contains(minute)) {
      minute = getClosestMinute(possibleMinutes, minute);
    }
    return minute ~/ widget.minuteIncrement;
  }

  void handleDateChanged(material.TimeOfDay date) {
    setState(() => time = date);
  }

  void initControllers() {
    if (widget.selected == null && mounted) {
      setState(() => time = material.TimeOfDay.now());
    }
    _hourController = FixedExtentScrollController(
      initialItem: () {
        var hour = time.hour - 1;
        if (!widget.use24Format) {
          hour -= 12;
        }
        return hour;
      }(),
    );

    _minuteController =
        FixedExtentScrollController(initialItem: calcMinuteItem(time.minute));

    _amPmController = FixedExtentScrollController(initialItem: _isPm ? 1 : 0);
  }

  bool get _isPm => time.hour >= 12;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));

    final theme = FluentTheme.of(context);
    final locale = widget.locale ?? Localizations.maybeLocaleOf(context);

    Widget picker = Picker(
      pickerHeight: widget.popupHeight,
      pickerContent: (context) {
        return _TimePickerContentPopup(
          onCancel: widget.onCancel ?? () {},
          onChanged: (time) => widget.onChanged?.call(time),
          time: widget.selected ?? material.TimeOfDay.now(),
          amPmController: _amPmController,
          hourController: _hourController,
          minuteController: _minuteController,
          use24Format: widget.use24Format,
          minuteIncrement: widget.minuteIncrement,
          locale: locale,
        );
      },
      child: (context, open) => HoverButton(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        cursor: SystemMouseCursors.click,
        onPressed: () async {
          _hourController.dispose();
          _minuteController.dispose();
          _amPmController.dispose();
          initControllers();
          await open();
        },
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
                  color: widget.selected == null
                      ? theme.resources.textFillColorSecondary
                      : null,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 11.px),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 173, 173, 175),
                        width: 0.5,
                      ),
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(3),
                          bottomRight: Radius.circular(3))),
                  child: Row(key: _buttonKey, children: [
                    Text(
                      time.format(context),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 16.px,
                          height: 1.0,
                          color: theme.typography.subtitle!.color),
                    ),
                    const Spacer(),
                    const Icon(
                      material.Icons.arrow_drop_down_sharp,
                      size: 15,
                    )
                  ]),
                ),
              ),
            ),
          );
        },
      ),
    );

    return picker;
  }
}

class _TimePickerContentPopup extends StatefulWidget {
  const _TimePickerContentPopup({
    required this.time,
    required this.onChanged,
    required this.onCancel,
    required this.hourController,
    required this.minuteController,
    required this.amPmController,
    required this.use24Format,
    required this.minuteIncrement,
    required this.locale,
  });

  final FixedExtentScrollController hourController;
  final FixedExtentScrollController minuteController;
  final FixedExtentScrollController amPmController;

  final ValueChanged<material.TimeOfDay> onChanged;
  final VoidCallback onCancel;
  final material.TimeOfDay time;
  final Locale? locale;

  final bool use24Format;
  final int minuteIncrement;

  @override
  State<_TimePickerContentPopup> createState() =>
      __TimePickerContentPopupState();
}

class __TimePickerContentPopupState extends State<_TimePickerContentPopup> {
  bool get isAm => widget.amPmController.selectedItem == 0;

  late material.TimeOfDay localDate;

  @override
  void initState() {
    super.initState();
    localDate = widget.time;
    final possibleMinutes = List.generate(
      60 ~/ widget.minuteIncrement,
      (index) => index * widget.minuteIncrement,
    );

    if (!possibleMinutes.contains(localDate.minute)) {
      localDate = material.TimeOfDay(
        hour: localDate.hour,
        minute: getClosestMinute(possibleMinutes, localDate.minute),
      );
    }
  }

  void handleDateChanged(material.TimeOfDay time) {
    localDate = time;
    Future.delayed(const Duration(milliseconds: 1), () {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));
    final theme = FluentTheme.of(context);
    final localizations = FluentLocalizations.of(context);

    const divider = Divider(
      direction: Axis.vertical,
      style: DividerThemeData(
        verticalMargin: EdgeInsets.zero,
        horizontalMargin: EdgeInsets.zero,
      ),
    );
    final duration = theme.fasterAnimationDuration;
    final curve = theme.animationCurve;
    final hoursAmount = widget.use24Format ? 24 : 12;

    return Column(children: [
      Expanded(
        child: Stack(children: [
          PickerHighlightTile(),
          Row(children: [
            Expanded(
              child: PickerNavigatorIndicator(
                onBackward: () {
                  widget.hourController.navigateSides(
                    context,
                    false,
                    hoursAmount,
                  );
                },
                onForward: () {
                  widget.hourController.navigateSides(
                    context,
                    true,
                    hoursAmount,
                  );
                },
                child: ListWheelScrollView.useDelegate(
                  controller: widget.hourController,
                  childDelegate: ListWheelChildListDelegate(
                    children: List.generate(hoursAmount, (index) {
                      final hour = index + 1;
                      final realHour = () {
                        if (!widget.use24Format && localDate.hour > 12) {
                          return hour + 12;
                        }
                        return hour;
                      }();
                      final selected = localDate.hour == realHour;

                      return ListTile(
                        onPressed: selected
                            ? null
                            : () {
                                widget.hourController.animateToItem(
                                  index,
                                  duration: theme.mediumAnimationDuration,
                                  curve: theme.animationCurve,
                                );
                              },
                        title: Center(
                          child: Text(
                            _formatHour(hour, widget.locale!.toString()),
                            style: kPickerPopupTextStyle(context, selected),
                          ),
                        ),
                      );
                    }),
                  ),
                  itemExtent: kOneLineTileHeight,
                  diameterRatio: kPickerDiameterRatio,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    var hour = index + 1;
                    if (!widget.use24Format && !isAm) {
                      hour += 12;
                    }
                    handleDateChanged(material.TimeOfDay(
                      hour: hour,
                      minute: localDate.minute,
                    ));
                  },
                ),
              ),
            ),
            divider,
            Expanded(
              child: PickerNavigatorIndicator(
                onBackward: () {
                  widget.minuteController.navigateSides(
                    context,
                    false,
                    60,
                  );
                },
                onForward: () {
                  widget.minuteController.navigateSides(
                    context,
                    true,
                    60,
                  );
                },
                child: ListWheelScrollView.useDelegate(
                  controller: widget.minuteController,
                  childDelegate: ListWheelChildListDelegate(
                    children: List.generate(
                      60 ~/ widget.minuteIncrement,
                      (index) {
                        final minute = index * widget.minuteIncrement;
                        final selected = minute == localDate.minute;
                        return ListTile(
                          onPressed: selected
                              ? null
                              : () {
                                  widget.minuteController.animateToItem(
                                    index,
                                    duration: theme.mediumAnimationDuration,
                                    curve: theme.animationCurve,
                                  );
                                },
                          title: Center(
                            child: Text(
                              _formatMinute(minute, '${widget.locale}'),
                              style: kPickerPopupTextStyle(context, selected),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  itemExtent: kOneLineTileHeight,
                  diameterRatio: kPickerDiameterRatio,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    final minute = index * widget.minuteIncrement;
                    handleDateChanged(material.TimeOfDay(
                      hour: localDate.hour,
                      minute: minute,
                    ));
                  },
                ),
              ),
            ),
            if (!widget.use24Format) ...[
              divider,
              Expanded(
                child: PickerNavigatorIndicator(
                  onBackward: () {
                    widget.amPmController.animateToItem(
                      0,
                      duration: duration,
                      curve: curve,
                    );
                  },
                  onForward: () {
                    widget.amPmController.animateToItem(
                      1,
                      duration: duration,
                      curve: curve,
                    );
                  },
                  child: ListWheelScrollView(
                    controller: widget.amPmController,
                    itemExtent: kOneLineTileHeight,
                    physics: const FixedExtentScrollPhysics(),
                    children: [
                      () {
                        final selected = localDate.hour < 12;
                        return ListTile(
                          onPressed: selected
                              ? null
                              : () {
                                  widget.amPmController.animateToItem(
                                    0,
                                    duration: theme.mediumAnimationDuration,
                                    curve: theme.animationCurve,
                                  );
                                },
                          title: Center(
                            child: Text(
                              localizations.am,
                              style: kPickerPopupTextStyle(context, selected),
                            ),
                          ),
                        );
                      }(),
                      () {
                        final selected = localDate.hour >= 12;
                        return ListTile(
                          onPressed: selected
                              ? null
                              : () {
                                  widget.amPmController.animateToItem(
                                    1,
                                    duration: theme.mediumAnimationDuration,
                                    curve: theme.animationCurve,
                                  );
                                },
                          title: Center(
                            child: Text(
                              localizations.pm,
                              style: kPickerPopupTextStyle(context, selected),
                            ),
                          ),
                        );
                      }(),
                    ],
                    onSelectedItemChanged: (index) {
                      // setState(() {});
                      var hour = localDate.hour;
                      final isAm = index == 0;
                      if (!widget.use24Format) {
                        // If it was previously am and now it's pm
                        if (!isAm) {
                          hour += 12;
                          // If it was previously pm and now it's am
                        } else if (isAm) {
                          hour -= 12;
                        }
                      }
                      handleDateChanged(material.TimeOfDay(
                        hour: hour,
                        minute: localDate.minute,
                      ));
                    },
                  ),
                ),
              ),
            ],
          ]),
        ]),
      ),
      const Divider(
        style: DividerThemeData(
          verticalMargin: EdgeInsets.zero,
          horizontalMargin: EdgeInsets.zero,
        ),
      ),
      YesNoPickerControl(
        onChanged: () {
          Navigator.pop(context);
          widget.onChanged(localDate);
        },
        onCancel: () {
          Navigator.pop(context);
          widget.onCancel();
        },
      ),
    ]);
  }
}
