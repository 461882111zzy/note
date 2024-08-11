import 'package:dailyflowy/app/controllers/db.dart';
import 'package:dailyflowy/app/data/message.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';

class MessageController extends GetxController {
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

  Future<Id> addMessage(Message newMessage) async {
    return updateMessage(newMessage);
  }

  Future<void> deleteMessage(Id id) async {
    await asureInstance();
    _isar?.writeTxn(() async {
      await _isar?.messages.delete(id);
      Future.delayed(const Duration(milliseconds: 100), () {
        updateTime.value = DateTime.now().millisecondsSinceEpoch;
        updateTime.refresh();
      });
    });
  }

  Future<void> deleteMessages(List<Id> id) async {
    await asureInstance();
    _isar?.writeTxn(() async {
      await _isar?.messages.deleteAll(id);
      Future.delayed(const Duration(milliseconds: 100), () {
        updateTime.value = DateTime.now().millisecondsSinceEpoch;
        updateTime.refresh();
      });
    });
  }

  Future<Id> updateMessage(Message newMessage,
      {bool isNotifyRefresh = true}) async {
    await asureInstance();
    final id = await _isar!.writeTxn(() async {
      final res = await _isar!.messages.put(newMessage);
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

  Future<List<Message>?> findMessages(List<Id>? ids) async {
    if (ids == null || ids.isEmpty) {
      return null;
    }
    await asureInstance();

    QueryBuilder<Message, Message, QWhereClause> queryBuilder =
        _isar!.messages.where();

    for (var i = 0; i < ids.length - 1; i++) {
      queryBuilder = queryBuilder.idEqualTo(ids[i]).or();
    }
    return await queryBuilder.idEqualTo(ids[ids.length - 1]).findAll();
  }

  Future<List<Message>?> searchMessages(String keyword) async {
    if (keyword.isEmpty) {
      return null;
    }
    await asureInstance();

    return await _isar!.messages
        .filter()
        .msgContains(keyword)
        .limit(50)
        .findAll();
  }
}
