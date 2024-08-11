import 'package:isar/isar.dart';

abstract class JsonableData {
  Map<String, dynamic> toJson();

  void fromJson(Map<String, dynamic> json);
}

abstract class BaseData extends JsonableData {
  int? createTime;
  int? updateTime;

  @enumerated
  Status status = Status.unknown;

  @override
  Map<String, dynamic> toJson() {
    return {
      'createTime': createTime,
      'updateTime': updateTime,
      'status': status.index, // 使用枚举的名称进行序列化
    };
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    if (json.containsKey('createTime')) {
      createTime = json['createTime'];
    }
    if (json.containsKey('updateTime')) {
      updateTime = json['updateTime'];
    }
    if (json.containsKey('status')) {
      // 这里假设我们有一个从字符串转换为Status枚举的逻辑
      status = Status.values[json['status'] as int];
    } else {
      // 如果状态未提供或者格式不正确，设置默认值或抛出错误
      status = Status.unknown;
    }
  }
}

enum Status {
  unknown,
  deleted,
}
