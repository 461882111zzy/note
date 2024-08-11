import 'package:dailyflowy/app/controllers/db.dart';
import 'package:dailyflowy/app/data/asset.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';

class AssetsController extends GetxController {
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

  Future<Id> addAssetData(AssetData assetData) async {
    return updateAssetData(assetData);
  }

  Future<void> deleteAssetData(Id id) async {
    await asureInstance();
    await _isar?.writeTxn(() async {
      await _isar?.assetDatas.delete(id);
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      updateTime.value = DateTime.now().millisecondsSinceEpoch;
      updateTime.refresh();
    });
  }

  Future<void> deleteAssetDatas(List<Id> id) async {
    await asureInstance();
    await _isar?.writeTxn(() async {
      await _isar?.assetDatas.deleteAll(id);
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      updateTime.value = DateTime.now().millisecondsSinceEpoch;
      updateTime.refresh();
    });
  }

  Future<Id> updateAssetData(AssetData assetData,
      {bool isNotifyRefresh = true}) async {
    await asureInstance();
    final id = await _isar!.writeTxn(() async {
      final res = await _isar!.assetDatas.put(assetData);
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

  Future<List<AssetData>> getAllAssetData() async {
    await asureInstance();
    return await _isar!.assetDatas.where().findAll();
  }

  Future<List<AssetData>?> findAssetDatas(List<Id>? ids) async {
    if (ids == null || ids.isEmpty) {
      return null;
    }
    await asureInstance();

    QueryBuilder<AssetData, AssetData, QWhereClause> queryBuilder =
        _isar!.assetDatas.where();

    for (var i = 0; i < ids.length - 1; i++) {
      queryBuilder = queryBuilder.idEqualTo(ids[i]).or();
    }
    return await queryBuilder.idEqualTo(ids[ids.length - 1]).findAll();
  }

  Future<List<AssetData>?> findAssetDatasFilterType(
      List<Id>? ids, String type) async {
    if (ids == null || ids.isEmpty) {
      return null;
    }
    await asureInstance();

    QueryBuilder<AssetData, AssetData, QFilterCondition> queryBuilder =
        _isar!.assetDatas.filter().typeEqualTo(type).and();

    for (var i = 0; i < ids.length - 1; i++) {
      queryBuilder = queryBuilder.idEqualTo(ids[i]).or();
    }
    return await queryBuilder.idEqualTo(ids[ids.length - 1]).findAll();
  }

  Future<AssetData?> findByTitleAndType(String type, String title) async {
    await asureInstance();
    final value = await _isar!.assetDatas
        .filter()
        .typeEqualTo(type)
        .titleEqualTo(title)
        .findAll();
    return value.isNotEmpty ? value[0] : null;
  }

  Future<List<AssetData>?> getAssetDatasFilterType(
      String type, int offset, int limit) async {
    await asureInstance();

    return await _isar!.assetDatas
        .filter()
        .typeEqualTo(type)
        .sortByUpdateTimeDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  Future<List<AssetData>?> searchAssetDatasFilterType(
      String type, String keyword) async {
    await asureInstance();

    return await _isar!.assetDatas
        .filter()
        .typeEqualTo(type)
        .and()
        .group((q) => q
            .titleContains(keyword)
            .or()
            .contentContains(keyword, caseSensitive: false))
        .sortByUpdateTimeDesc()
        .limit(50)
        .findAll();
  }
}
