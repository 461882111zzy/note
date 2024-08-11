import 'package:dailyflowy/app/data/base_data.dart';
import 'package:isar/isar.dart';

part 'meeting.g.dart';

@collection
class Meeting extends BaseData {
  Id id = Isar.autoIncrement;

  late String title;

  DateTime? from;

  DateTime? to;

  int? background;

  late bool isAllDay;

  String? notes;

  String? recurrenceRule;

  // 会议关联的taskId
  int? taskId;

  @override
  void fromJson(Map<String, dynamic> json) {
    title = json['title'];
    from = DateTime.parse(json['from']);
    to = DateTime.parse(json['to']);
    background = json['background'];
    isAllDay = json['isAllDay'];
    notes = json['notes'];
    recurrenceRule = json['recurrenceRule'];
    taskId = json['taskId'];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'title': title,
      'from': from?.toString(),
      'to': to?.toString(),
      'background': background,
      'isAllDay': isAllDay,
      'notes': notes ?? '',
      'recurrenceRule': recurrenceRule ?? '',
      'taskId': taskId,
      ...super.toJson()
    };
  }
}
