import 'package:dailyflowy/app/data/base_data.dart';
import 'package:isar/isar.dart';
part 'message.g.dart';

@collection
class Message extends JsonableData {
  Id id = Isar.autoIncrement;
  late int time;
  late String msg;

  @override
  void fromJson(Map<String, dynamic> json) {
    // 解析 JSON 数据并赋值给各个属性
    if (json.containsKey('id')) {
      id = json['id'] as Id;
    }

    if (json.containsKey('time') && json['time'] is int) {
      time = json['time'];
    }

    if (json.containsKey('msg') && json['msg'] is String) {
      msg = json['msg'];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'time': time,
      'msg': msg,
    };
  }
}
