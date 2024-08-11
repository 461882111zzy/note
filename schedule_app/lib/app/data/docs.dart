import 'package:dailyflowy/app/data/base_data.dart';
import 'package:isar/isar.dart';
part 'docs.g.dart';

@collection
class DocData extends BaseData {
  Id id = Isar.autoIncrement;
  late String title;
  late String? content;

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

    if (json.containsKey('content') && json['content'] is String) {
      content = json['content'];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'title': title,
      'content': content ?? '',
    };
  }
}
