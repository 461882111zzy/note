import 'package:dailyflowy/app/controllers/db.dart';
import 'package:dailyflowy/app/data/task.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';

class TaskController extends GetxController {
  Isar? _isar;

  final updateTime = 0.obs;

  late Future<Isar> _isarFuture;

  @override
  void onInit() async {
    super.onInit();
    _isarFuture = Db.get();
  }

  Future<void> asureInstance() async {
    _isar ??= await _isarFuture;
  }

  Future<Id> addTask(Task newTask) async {
    return updateTask(newTask);
  }

  Future<void> deleteTask(Id id) async {
    await asureInstance();
    await _isar?.writeTxn(() async {
      await _isar?.tasks.delete(id);
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      updateTime.value = DateTime.now().millisecondsSinceEpoch;
      updateTime.refresh();
    });
  }

  Future<void> deleteTasks(List<Id> id) async {
    await asureInstance();
    await _isar?.writeTxn(() async {
      await _isar?.tasks.deleteAll(id);
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      updateTime.value = DateTime.now().millisecondsSinceEpoch;
      updateTime.refresh();
    });
  }

  Future<Id> updateTask(Task newTask, {bool isNotifyRefresh = true}) async {
    await asureInstance();
    final id = await _isar!.writeTxn(() async {
      final res = await _isar!.tasks.put(newTask);
      return res;
    });

    if (isNotifyRefresh) {
      Future.delayed(const Duration(milliseconds: 100), () {
        updateTime.value = DateTime.now().millisecondsSinceEpoch;
        updateTime.refresh();
      });
    }

    return id;
  }

  Future<List<Task>?> findTasks(List<Id>? ids) async {
    if (ids == null || ids.isEmpty) {
      return null;
    }
    await asureInstance();

    QueryBuilder<Task, Task, QWhereClause> queryBuilder = _isar!.tasks.where();

    for (var i = 0; i < ids.length - 1; i++) {
      queryBuilder = queryBuilder.idEqualTo(ids[i]).or();
    }
    return await queryBuilder.idEqualTo(ids[ids.length - 1]).findAll();
  }

  Future<List<Task>?> getRecentEditedTasks() async {
    await asureInstance();
    final tasks =
        await _isar!.tasks.where().sortByUpdateTimeDesc().limit(5).findAll();
    return tasks;
  }

  Future<List<Task>?> searchTasks(String keyword) async {
    if (keyword.isEmpty) {
      return null;
    }
    await asureInstance();
    //final match = r'(?="insert":").?*' + keyword;
    return await _isar!.tasks
        .filter()
        .titleContains(keyword)
        .or()
        .descMatches(keyword)
        .limit(50)
        .findAll();
  }

  Future<List<Task>?> getSubTasks(Task task) async {
    return await findTasks(task.subTasks);
  }

  Future<Task?> getMainTask(Task subTask) async {
    await asureInstance();
    final res = await _isar!.tasks
        .filter()
        .subTasksIsNotNull()
        .and()
        .subTasksIsNotEmpty()
        .and()
        .subTasksElementEqualTo(subTask.id)
        .findAll();
    if (res.isNotEmpty) {
      return res[0];
    } else {
      return null;
    }
  }

  Future<Task?> findTaskByDueDateMeeting(int meetingId) async {
    await asureInstance();
    final res = await _isar!.tasks
        .filter()
        .dueDateMeetingIdEqualTo(meetingId)
        .findAll();
    if (res.isNotEmpty) {
      return res[0];
    } else {
      return null;
    }
  }
}
