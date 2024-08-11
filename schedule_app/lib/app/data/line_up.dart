import 'package:dailyflowy/app/data/base_data.dart';
import 'package:isar/isar.dart';

part 'line_up.g.dart';

@collection
class LineUp extends BaseData {
  Id id = Isar.autoIncrement;

  int? taskId;
  int? meetingId;

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);

    if (json.containsKey('taskId') && json['taskId'] is num) {
      taskId = json['taskId'] as int;
    }
    if (json.containsKey('meetingId') && json['meetingId'] is num) {
      meetingId = json['meetingId'] as int;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id.toString(),

      // 从BaseData继承来的字段
      ...super.toJson(),

      'taskId': taskId,
      'meetingId': meetingId,
    };
  }
}
