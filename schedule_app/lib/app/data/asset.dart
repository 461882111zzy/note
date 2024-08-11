import 'package:dailyflowy/app/data/base_data.dart';
import 'package:isar/isar.dart';
part 'asset.g.dart';

@collection
class AssetData extends BaseData {
  Id id = Isar.autoIncrement;
  late String title;
  late String? content;
  late String? type;

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

    if (json.containsKey('type')) {
      // 这里假设从 JSON 字符串解析类型到实际的枚举值
      type = json['type'] as String;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'title': title,
      'content': content ?? '',
      'type': type ?? '',
      ...super.toJson(),
    };
  }
}

const assetTypeLink = 'link';
const assetTypeFile = 'file';
const assetTypeNote = 'note';
const assetTypePlugin = 'plugin';
