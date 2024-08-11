import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart' as appflowy_editor;
import 'package:dailyflowy/app/controllers/line_up_controller.dart';
import 'package:dailyflowy/app/data/asset.dart';
import 'package:dailyflowy/app/data/line_up.dart';
import 'package:dailyflowy/app/data/meeting.dart';
import 'package:dailyflowy/app/data/workspace.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;

import '../data/task.dart';
import 'calendar_controller.dart';
import 'task_controller.dart';
import 'package:get/get.dart';

import 'workspace_controller.dart';

extension FolderDataEx on FolderData {
  bool isSameTo(FolderData? other) {
    if (other == null) return false;
    return title == other.title && parentId == other.parentId;
  }

  void addTask(int taskId) {
    if (tasks != null && tasks!.contains(taskId)) return;
    tasks = <int>[...?tasks, taskId];
  }

  void deleteTask(int taskId) {
    tasks = <int>[...?tasks]..remove(taskId);
  }

  void addAsset(int id) {
    if (assets != null && assets!.contains(id)) return;
    assets = <int>[...?assets, id];
  }

  void deleteAsset(int id) {
    assets = <int>[...?assets]..remove(id);
  }

  Future<void> update() async {
    final workSpaceController = Get.find<WorkSpaceController>();
    final lastFolder = await workSpaceController.findFolder(title, parentId);
    if (lastFolder == null) return;
    tasks = lastFolder.tasks;
    assets = lastFolder.assets;
  }
}

extension WorkspaceDataEx on WorkSpaceData {
  bool isSameTo(WorkSpaceData? other) {
    if (other == null) return false;
    return title == other.title && id == other.id;
  }

  void addFolder(FolderData folderData) {
    if (dirs != null &&
        dirs!.indexWhere((element) => element.title == folderData.title) > 0) {
      return;
    }

    dirs = <FolderData>[...?dirs, folderData];
  }

  void deleteFolder(FolderData folderData) {
    dirs = <FolderData>[...?dirs]
      ..removeWhere((element) => element.title == folderData.title);
  }

  void insertFolder(FolderData folder, FolderData target, bool before) {
    deleteFolder(folder);
    final index =
        dirs?.indexWhere((element) => element.title == target.title) ?? 0;
    dirs = <FolderData>[...?dirs]..insert(before ? index : index + 1, folder);
  }
}

Future<void> deleteSubTask(Task sub, Task task) async {
  final taskController = Get.find<TaskController>();
  await taskController.deleteTask(sub.id);
  final List<int> taskids = [];
  taskids.addAll(task.subTasks!);
  taskids.remove(sub.id);
  task.subTasks = taskids;
  await taskController.updateTask(task, isNotifyRefresh: false);
}

Future<void> deleteTask(Task task, FolderData? folderData) async {
  final taskController = Get.find<TaskController>();
  final workspaceController = Get.find<WorkSpaceController>();
  task.subTasks?.forEach((element) async {
    await taskController.deleteTask(element);
  });
  await taskController.deleteTask(task.id);

  if (folderData == null) return;

  final lastFolderData = await workspaceController.findFolder(
      folderData.title, folderData.parentId);

  if (lastFolderData != null) {
    if (lastFolderData.tasks != null) {
      for (int i = 0; i < lastFolderData.tasks!.length; i++) {
        if (lastFolderData.tasks![i] == task.id) {
          final List<int> taskids = [];
          taskids.addAll(lastFolderData.tasks!);
          taskids.removeAt(i);
          lastFolderData.tasks = taskids;
          await workspaceController.updateFolder(lastFolderData);
        }
      }
    }
  }
}

void moveTaskBetweenFolder(Task k, FolderData? from, FolderData to) async {
  final workspaceController = Get.find<WorkSpaceController>();
  if (from != null) {
    if (from.isSameTo(to)) {
      return;
    }
    final fromFolder =
        await workspaceController.findFolder(from.title, from.parentId);
    fromFolder?.deleteTask(k.id);
    if (fromFolder != null) {
      await workspaceController.updateFolder(fromFolder);
    }
  }

  final toFolder = await workspaceController.findFolder(to.title, to.parentId);
  toFolder?.addTask(k.id);
  if (toFolder != null) {
    await workspaceController.updateFolder(toFolder);
  }
}

Future moveAssetBetweenFolder(
    AssetData assetData, FolderData? from, FolderData to) async {
  final workspaceController = Get.find<WorkSpaceController>();
  if (from != null) {
    if (from.isSameTo(to)) {
      return;
    }
    final fromFolder =
        await workspaceController.findFolder(from.title, from.parentId);
    fromFolder?.deleteAsset(assetData.id);
    if (fromFolder != null) {
      await workspaceController.updateFolder(fromFolder);
    }
  }

  final toFolder = await workspaceController.findFolder(to.title, to.parentId);
  toFolder?.addAsset(assetData.id);
  if (toFolder != null) {
    await workspaceController.updateFolder(toFolder);
  }
}

Future<void> moveFolderToOtherWorkspace(
    FolderData folder, int targerWorkSpaceId) async {
  final workspaceController = Get.find<WorkSpaceController>();
  final folderData = folder;
  //folderData从原来的workSpaceData里移除掉，然后辅到新的workSpaceData里
  await workspaceController.deleteFolder(folderData);
  folderData.parentId = targerWorkSpaceId;
  await workspaceController.addFolder(folderData, targerWorkSpaceId);
}

Future<void> addSubTask(String text, Task task) async {
  final taskController = Get.find<TaskController>();
  final subTask = Task()
    ..title = text
    ..priority = Priority.low
    ..taskStatus = TaskStatus.unstart
    ..createTime = DateTime.now().millisecondsSinceEpoch;
  subTask.id = await taskController.addTask(subTask);

  List<int> tasks = [];
  tasks.addAll(task.subTasks ?? []);
  tasks.add(subTask.id);
  task.subTasks = tasks;
  await taskController.updateTask(task);
}

Future<Meeting> setTaskDueDate(Task task, DateTime date) async {
  final calendarController = Get.find<CalendarController>();
  if (task.dueDateMeetingId == null) {
    Meeting meeting = Meeting()
      ..isAllDay = true
      ..to = date
      ..taskId = task.id
      ..notes = null
      ..title = task.title
      ..createTime = DateTime.now().millisecondsSinceEpoch;

    final id = await calendarController.addMeeting(meeting);
    meeting.id = id;
    task.dueDateMeetingId = id;
    final taskController = Get.find<TaskController>();
    taskController.updateTask(task);
    return meeting;
  } else {
    final meeting =
        await calendarController.findMeetings([task.dueDateMeetingId]);
    if (meeting != null && meeting.isNotEmpty) {
      meeting[0].to = date;
      calendarController.updateMeeting(meeting[0]);
    }
    return meeting![0];
  }
}

Future<void> addToLineUp(Task task) async {
  final lineupController = Get.find<LineUpController>();
  final query = await lineupController.getLineUp(task.id);
  if (query != null) {
    return;
  }

  final val = LineUp()
    ..taskId = task.id
    ..createTime = DateTime.now().millisecondsSinceEpoch;
  await lineupController.addLineUp(val);
}

Future<String?> fetchHtml(String url) async {
  final response = await Dio().get(url);
  if (response.statusCode == 200) {
    return response.data;
  } else {
    return null;
  }
}

String? parseIconUrl(String? html, String host) {
  if (html == null) {
    return null;
  }
  var document = parse(html);
  var linkTags = document.getElementsByTagName('link');
  for (var tag in linkTags) {
    var relAttribute = tag.attributes['rel'];
    if (relAttribute != null &&
        (relAttribute == 'icon' || relAttribute == 'shortcut icon')) {
      var hrefAttribute = tag.attributes['href'];
      if (hrefAttribute != null && hrefAttribute.isNotEmpty) {
        if (hrefAttribute.startsWith('//')) {
          return 'http:$hrefAttribute';
        } else if (hrefAttribute.startsWith('http')) {
          return hrefAttribute;
        }
        return host + hrefAttribute;
      }
    }
  }
  return null;
}

String? parseTitle(String? html) {
  if (html == null) {
    return null;
  }
  var doc = parse(html);
  var titleElement = doc.querySelector('title');
  if (titleElement != null) {
    return titleElement.text;
  } else {
    return null;
  }
}

extension DocumentEx on appflowy_editor.Document {
  String sumary({int maxLength = 50}) {
    return _sumary(root, maxLength);
  }

  ///从Document中解析出简要的信息
  /// {
  ///   'document': {
  ///     'type': 'page',
  ///     'children': [
  ///       {
  ///         'type': 'paragraph',
  ///         'data': {
  ///           'delta': [
  ///             { 'insert': 'Welcome ' },
  ///             { 'insert': 'to ' },
  ///             { 'insert': 'AppFlowy!' }
  ///           ]
  ///         }
  ///       }
  ///     ]
  ///   }
  /// }
  /// ```

  String _sumary(appflowy_editor.Node root, int maxLength) {
    if (maxLength <= 0) {
      return '';
    }

    var buffer = StringBuffer();

    final delta = root.delta;
    if (delta != null) {
      buffer.write(delta.toPlainText());
    }
    if (buffer.length > maxLength) {
      return buffer.toString().substring(0, min(buffer.length, maxLength));
    }

    if (root.children.isNotEmpty) {
      for (var child in root.children) {
        buffer.write(_sumary(child, maxLength - buffer.length));
        if (buffer.length > maxLength) {
          return buffer.toString().substring(0, min(buffer.length, maxLength));
        }
      }
    }

    return buffer.toString().substring(0, min(buffer.length, maxLength));
  }

  String toPlainText() {
    return _toPlainText(root);
  }

  String _toPlainText(appflowy_editor.Node root) {
    var buffer = StringBuffer();

    final delta = root.delta;
    if (delta != null) {
      buffer.write(delta.toPlainText());
    }

    if (root.children.isNotEmpty) {
      for (var child in root.children) {
        buffer.write(_toPlainText(child));
      }
    }

    return buffer.toString();
  }
}
