import 'package:dailyflowy/app/data/base_data.dart';
import 'package:isar/isar.dart';

part 'task.g.dart';

@collection
class Task extends BaseData {
  Id id = Isar.autoIncrement;
  late String title;
  String? desc;
  List<Id>? messages;
  List<Id>? meetings;

  int? dueDateMeetingId;

  @enumerated
  late Priority priority;

  @enumerated
  late TaskStatus taskStatus;

  List<Id>? subTasks;

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    // 解析 JSON 数据并赋值给各个属性
    if (json.containsKey('id')) {
      id = json['id'] as Id;
    }

    if (json.containsKey('title') && json['title'] is String) {
      title = json['title'];
    }

    if (json.containsKey('desc') && json['desc'] is String) {
      desc = json['desc'];
    }

    if (json.containsKey('messages') && json['messages'] is List) {
      messages = json['messages'] as List<Id>;
    }

    if (json.containsKey('meetings') && json['meetings'] is List) {
      meetings = json['meetings'] as List<Id>;
    }

    if (json.containsKey('dueDateMeetingId') &&
        json['dueDateMeetingId'] is int) {
      dueDateMeetingId = json['dueDateMeetingId'];
    }

    if (json.containsKey('priority') && json['priority'] is int) {
      priority = Priority.values[json['priority'] as int];
    }

    if (json.containsKey('taskStatus') && json['taskStatus'] is int) {
      taskStatus = TaskStatus.values[json['taskStatus'] as int];
    }

    if (json.containsKey('subTasks') && json['subTasks'] is List) {
      subTasks = json['subTasks'] as List<Id>;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'title': title,
      'desc': desc,
      'messages': messages,
      'meetings': meetings,
      'dueDateMeetingId': dueDateMeetingId,
      'priority': priority.index,
      'taskStatus': taskStatus.index,
      'subTasks': subTasks,
      ...super.toJson()
    };
  }
}

enum Priority {
  low,
  medium,
  high,
}

enum TaskStatus { unstart, processing, done, delete }
