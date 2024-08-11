import 'package:dailyflowy/app/controllers/db.dart';
import 'package:dailyflowy/app/data/line_up.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';

class LineUpController extends GetxController {
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

  Future<Id> addLineUp(LineUp newLineUp) async {
    return updateLineUp(newLineUp);
  }

  Future<void> deleteLineUp(Id id) async {
    await asureInstance();
    _isar?.writeTxn(() async {
      await _isar?.lineUps.delete(id);
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      updateTime.value = DateTime.now().millisecondsSinceEpoch;
      updateTime.refresh();
    });
  }

  Future<void> deleteLineUps(List<Id> id) async {
    await asureInstance();
    _isar?.writeTxn(() async {
      await _isar?.lineUps.deleteAll(id);
      Future.delayed(const Duration(milliseconds: 100), () {
        updateTime.value = DateTime.now().millisecondsSinceEpoch;
        updateTime.refresh();
      });
    });
  }

  Future<Id> updateLineUp(LineUp newLineUp,
      {bool isNotifyRefresh = true}) async {
    await asureInstance();
    final id = await _isar!.writeTxn(() async {
      final res = await _isar!.lineUps.put(newLineUp);
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

  Future<List<LineUp>?> findLineUps(List<Id>? ids) async {
    if (ids == null || ids.isEmpty) {
      return null;
    }
    await asureInstance();

    QueryBuilder<LineUp, LineUp, QWhereClause> queryBuilder =
        _isar!.lineUps.where();

    for (var i = 0; i < ids.length - 1; i++) {
      queryBuilder = queryBuilder.idEqualTo(ids[i]).or();
    }
    return await queryBuilder.idEqualTo(ids[ids.length - 1]).findAll();
  }

  Future<List<LineUp>?> getAll() async {
    await asureInstance();
    return await _isar!.lineUps.where().findAll();
  }

  Future<LineUp?> getLineUp(int taskId) async {
    await asureInstance();
    return await _isar!.lineUps
        .where()
        .filter()
        .taskIdEqualTo(taskId)
        .findFirst();
  }
}
