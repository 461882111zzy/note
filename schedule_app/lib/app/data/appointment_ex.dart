import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class AppointmentEx extends Appointment {
  AppointmentEx({
    super.startTimeZone,
    super.endTimeZone,
    super.recurrenceRule,
    super.isAllDay = false,
    super.notes,
    super.location,
    super.resourceIds,
    super.recurrenceId,
    super.id,
    required super.startTime,
    required super.endTime,
    super.subject = '',
    super.color = const Color(0xFF49DCBB),
    super.recurrenceExceptionDates,
  });
}
