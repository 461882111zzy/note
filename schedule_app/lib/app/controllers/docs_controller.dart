import 'package:dailyflowy/app/data/docs.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';

import 'db.dart';

class DocsController extends GetxController {
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

  Future<Id> addNote(DocData newNote) async {
    return updateNote(newNote);
  }

  Future<void> deleteNote(Id id) async {
    await asureInstance();
    await _isar?.writeTxn(() async {
      await _isar?.docDatas.delete(id);
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      updateTime.value = DateTime.now().millisecondsSinceEpoch;
      updateTime.refresh();
    });
  }

  Future<void> deleteNotes(List<Id> id) async {
    await asureInstance();
    await _isar?.writeTxn(() async {
      await _isar?.docDatas.deleteAll(id);
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      updateTime.value = DateTime.now().millisecondsSinceEpoch;
      updateTime.refresh();
    });
  }

  Future<Id> updateNote(DocData newNote, {bool isNotifyRefresh = true}) async {
    await asureInstance();
    final id = await _isar!.writeTxn(() async {
      final res = await _isar!.docDatas.put(newNote);
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

  Future<List<DocData>?> findNotes(List<Id>? ids) async {
    if (ids == null || ids.isEmpty) {
      return null;
    }
    await asureInstance();

    QueryBuilder<DocData, DocData, QWhereClause> queryBuilder =
        _isar!.docDatas.where();

    for (var i = 0; i < ids.length - 1; i++) {
      queryBuilder = queryBuilder.idEqualTo(ids[i]).or();
    }
    return await queryBuilder.idEqualTo(ids[ids.length - 1]).findAll();
  }

  Future<List<DocData>?> searchNotes(String keyword) async {
    if (keyword.isEmpty) {
      return null;
    }

    await asureInstance();
    return await _isar!.docDatas
        .filter()
        .titleContains(keyword)
        .or()
        .contentMatches('{"insert": "$keyword"}', caseSensitive: false)
        .limit(50)
        .findAll();
  }
}
