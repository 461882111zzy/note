import 'package:dailyflowy/app/data/base_data.dart';
import 'package:isar/isar.dart';

part 'workspace.g.dart';

@collection
class WorkSpaceData extends BaseData {
  Id id = Isar.autoIncrement;
  late String title;
  List<FolderData>? dirs;

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    if (json.containsKey('id') && json['id'] is int) {
      id = json['id'] as Id;
    }
    if (json.containsKey('title') && json['title'] is String) {
      title = json['title'];
    }
    if (json.containsKey('dirs') && json['dirs'] is List) {
      dirs =
          (json['dirs'] as List).map((e) => FolderData()..fromJson(e)).toList();
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'title': title,
      'dirs': dirs?.map((e) => e.toJson()).toList(),
      ...super.toJson()
    };
  }
}

@embedded
class FolderData extends BaseData {
  late int parentId;
  late String title;
  List<Id>? tasks;
  List<Id>? assets;

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    if (json.containsKey('parentId') && json['parentId'] is int) {
      parentId = json['parentId'];
    }
    if (json.containsKey('title') && json['title'] is String) {
      title = json['title'];
    }
    if (json.containsKey('tasks') && json['tasks'] is List) {
      tasks = json['tasks'] as List<Id>;
    }
    if (json.containsKey('assets') && json['assets'] is List) {
      assets = json['assets'] as List<Id>;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'parentId': parentId,
      'title': title,
      'tasks': tasks,
      'assets': assets,
      ...super.toJson()
    };
  }
}
