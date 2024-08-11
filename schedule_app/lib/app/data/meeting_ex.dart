import 'package:isar/isar.dart';

import 'meeting.dart';

class MeetingEx extends Meeting {
  late Object identify;

  @override
  Id get id {
    throw Exception('can\'t call');
  }
}
