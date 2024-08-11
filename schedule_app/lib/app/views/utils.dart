import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as ui;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

Widget maybeTooltip({required Widget child, String? message}) =>
    (message ?? '').isNotEmpty
        ? Tooltip(message: message!, child: child)
        : child;

extension DoubleEx on double {
  double get px => this * 3 / 4;
}

extension IntEx on int {
  double get px => this * 3 / 4;
}

extension DateTimeEx on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return now.year == year && now.month == month && now.day == day;
  }

  bool isSameDate(DateTime other) {
    return other.year == year && other.month == month && other.day == day;
  }

  DateTime startOfDay() {
    return DateTime(year, month, day);
  }

  DateTime endOfDay() {
    return DateTime(year, month, day, 23, 59, 59);
  }
}

void showToast(BuildContext context, String title, String? message,
    {ui.InfoBarSeverity severity = ui.InfoBarSeverity.warning}) {
  ui.displayInfoBar(context, duration: const Duration(seconds: 2),
      builder: (context, close) {
    return SizedBox(
      height: 50,
      child: ui.InfoBar(
        style: const ui.InfoBarThemeData(
          padding: EdgeInsets.only(left: 10, right: 10),
        ),
        title: Text(title),
        content: message != null && message.isNotEmpty ? Text(message) : null,
        action: ui.IconButton(
          icon: const Icon(
            ui.FluentIcons.clear,
            size: 15,
          ),
          onPressed: close,
        ),
        severity: severity,
      ),
    );
  });
}

Future<DateTime?> showDatePickerEx(ui.BuildContext context,
    {DateTime? initDate}) async {
  return ui.showDialog<DateTime>(
      context: context,
      barrierColor: Colors.black12,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          child: ui.FlyoutContent(
            padding: ui.EdgeInsets.zero,
            child: ui.SizedBox(
              width: 400,
              height: 300,
              child: Localizations.override(
                context: context,
                locale: const Locale('zh'),
                child: SfDateRangePicker(
                    toggleDaySelection: true,
                    confirmText: '确定',
                    cancelText: '取消',
                    showActionButtons: true,
                    backgroundColor:
                        ui.FluentTheme.of(context).micaBackgroundColor,
                    headerStyle: DateRangePickerHeaderStyle(
                        backgroundColor:
                            ui.FluentTheme.of(context).micaBackgroundColor),
                    initialSelectedDate: initDate,
                    onCancel: () {
                      Navigator.of(context).pop(null);
                    },
                    onSubmit: (value) {
                      if (value is DateTime) {
                        Navigator.of(context).pop(value);
                        return;
                      }
                      Navigator.of(context).pop(null);
                    }),
              ),
            ),
          ),
        );
      });
}

Future<File> copyFile(String sourcePath, String destinationPath) async {
  File sourceFile = File(sourcePath);
  File destinationFile = File(destinationPath);
  return await sourceFile.copy(destinationFile.path);
}
