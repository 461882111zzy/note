import 'package:dailyflowy/app/controllers/utils.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:dailyflowy/app/controllers/db.dart';
import 'package:tuple/tuple.dart';
import '../data/workspace.dart';

class WorkSpaceController extends GetxController {
  Isar? _isar;
  final workspaces = <WorkSpaceData>[].obs;
  late Future _isarFuture;

  @override
  Future<void> onInit() async {
    super.onInit();
    _isarFuture = Future(() async {
      final isar = await Db.get();

      workspaces.addAll(await isar.workSpaceDatas
          .filter()
          .titleIsNotEmpty()
          .sortByCreateTime()
          .findAll());

      isar.workSpaceDatas.where().watch(fireImmediately: true).listen((event) {
        workspaces.value = event;
        workspaces.refresh();
      });

      _isar = isar;
    });
  }

  Future<void> asureInstance() async {
    _isar ??= await _isarFuture;
  }

  void addWorkSpace(WorkSpaceData workSpace) {
    updateWorkSpace(workSpace);
  }

  Future<void> updateWorkSpace(WorkSpaceData workSpace) async {
    await asureInstance();
    await _isar?.writeTxn(() async {
      await _isar?.workSpaceDatas.put(workSpace); // delete
    });
  }

  Future<void> addFolder(FolderData data, int workSpaceId) async {
    await asureInstance();
    for (var i = 0; i < workspaces.length; i++) {
      if (workSpaceId == workspaces[i].id) {
        data.parentId = workSpaceId;
        workspaces[i].addFolder(data);
        return await updateWorkSpace(workspaces[i]);
      }
    }
  }

  Future<void> updateFolder(FolderData data) async {
    await asureInstance();
    for (var i = 0; i < workspaces.length; i++) {
      if (data.parentId == workspaces[i].id) {
        for (int j = 0; j < workspaces[i].dirs!.length; j++) {
          if (data.title == workspaces[i].dirs![j].title) {
            workspaces[i].dirs![j] = data;
            return await updateWorkSpace(workspaces[i]);
          }
        }
      }
    }
  }

  Future<FolderData?> findFolder(String title, int workSpaceId) async {
    await asureInstance();
    for (var i = 0; i < workspaces.length; i++) {
      if (workSpaceId == workspaces[i].id) {
        for (int j = 0; j < workspaces[i].dirs!.length; j++) {
          if (title == workspaces[i].dirs![j].title) {
            return workspaces[i].dirs![j];
          }
        }
      }
    }
    return null;
  }

  Future<WorkSpaceData?> findWorkspace(int workSpaceId) async {
    await asureInstance();
    for (var i = 0; i < workspaces.length; i++) {
      if (workSpaceId == workspaces[i].id) {
        return workspaces[i];
      }
    }
    return null;
  }

  Future<WorkSpaceData?> findWorkspace2(String workSpaceTitle) async {
    await asureInstance();
    for (var i = 0; i < workspaces.length; i++) {
      if (workSpaceTitle == workspaces[i].title) {
        return workspaces[i];
      }
    }
    return null;
  }

  Future<void> deleteFolder(FolderData data) async {
    await asureInstance();
    for (var i = 0; i < workspaces.length; i++) {
      if (data.parentId == workspaces[i].id) {
        workspaces[i].deleteFolder(data);
        return await updateWorkSpace(workspaces[i]);
      }
    }
  }

  void delWorkSpace(WorkSpaceData workSpace) async {
    await asureInstance();
    await _isar!.writeTxn(() async {
      await _isar!.workSpaceDatas.delete(workSpace.id); // delete
    });
  }

  Future<bool> hasDuplicateWorkSpace(String title) async {
    await asureInstance();
    // ignore: invalid_use_of_protected_member
    for (var element in workspaces.value) {
      if (element.title == title) {
        return true;
      }
    }
    return false;
  }

  bool hasDuplicateFolder(WorkSpaceData workspace, String title) {
    if (workspace.dirs == null) {
      return false;
    }
    for (var element in workspace.dirs!) {
      if (element.title == title) {
        return true;
      }
    }
    return false;
  }

  FolderData? findByAssetId(int assetId) {
    FolderData? folderData;
    for (var workSpace in workspaces) {
      if (workSpace.dirs == null) {
        continue;
      }
      for (var folder in workSpace.dirs!) {
        if (folder.assets != null && folder.assets!.contains(assetId)) {
          folderData = folder;
          break;
        }
      }

      if (folderData == null) {
        continue;
      } else {
        break;
      }
    }

    return folderData;
  }

  Future<Tuple2<WorkSpaceData, FolderData>?> findFolderByTaskId(
      int taskId) async {
    await asureInstance();
    FolderData? folderData;
    WorkSpaceData? workSpaceData;
    for (var workSpace in workspaces) {
      if (workSpace.dirs == null) {
        continue;
      }
      for (var folder in workSpace.dirs!) {
        if (folder.tasks != null && folder.tasks!.contains(taskId)) {
          folderData = folder;
          workSpaceData = workSpace;
          break;
        }
      }

      if (folderData == null) {
        continue;
      } else {
        break;
      }
    }
    if (folderData == null) {
      return null;
    }

    return Tuple2(workSpaceData!, folderData);
  }
}
