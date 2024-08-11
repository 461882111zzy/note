import 'package:dailyflowy/app/data/meeting.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';

import 'db.dart';

class CalendarController extends GetxController {
  Isar? _isar;

  final updateTime = 0.obs;
  final lastUpdateMeetings = (Meeting()
        ..title = ''
        ..isAllDay = false)
      .obs;

  final lastRemoveMeetings = <int>[].obs;

  late Future<Isar> _isarFuture;

  @override
  void onInit() async {
    super.onInit();
    _isarFuture = Db.get();
  }

  Future<void> asureInstance() async {
    _isar ??= await _isarFuture;
  }

  Future<Id> updateMeeting(Meeting meeting,
      {bool isNotifyRefresh = true, int? millisecondsSinceEpoch}) async {
    await asureInstance();
    final id = await _isar!.writeTxn(() async {
      final res = await _isar!.meetings.put(meeting);
      return res;
    });

    if (isNotifyRefresh) {
      Future.delayed(const Duration(milliseconds: 100), () {
        updateTime.value =
            millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;
        updateTime.refresh();
      });
    }
    lastUpdateMeetings.value = meeting;
    return id;
  }

  Future<Id> addMeeting(Meeting meeting) async {
    return updateMeeting(meeting);
  }

  Future<void> deleteMeeting(Id id) async {
    await asureInstance();
    await _isar?.writeTxn(() async {
      await _isar?.meetings.delete(id);
    });
    Future.delayed(const Duration(milliseconds: 20), () {
      updateTime.value = DateTime.now().millisecondsSinceEpoch;
      updateTime.refresh();
    });

    lastRemoveMeetings.value = [id];
  }

  Future<void> deleteMeetings(List<Id> id) async {
    await asureInstance();
    await _isar?.writeTxn(() async {
      await _isar?.meetings.deleteAll(id);
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      updateTime.value = DateTime.now().millisecondsSinceEpoch;
      updateTime.refresh();
    });

    lastRemoveMeetings.value = id;
  }

  Future<List<Meeting>?> findMeetings(List<Id?> ids) async {
    await asureInstance();
    if (ids.isEmpty) {
      return null;
    }
    await asureInstance();

    QueryBuilder<Meeting, Meeting, QWhereClause> queryBuilder =
        _isar!.meetings.where();

    for (var i = 0; i < ids.length - 1; i++) {
      queryBuilder = queryBuilder.idEqualTo(ids[i]!).or();
    }
    return await queryBuilder.idEqualTo(ids[ids.length - 1]!).findAll();
  }

  Future<List<Meeting>?> findMeetingsByDate(DateTime from, DateTime to) async {
    await asureInstance();
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day + 1);
    return await _isar?.meetings
        .where()
        .filter()
        .group((q) {
          return q
              .fromGreaterThan(start, include: true)
              .and()
              .fromLessThan(end);
        })
        .or()
        .group((q) {
          return q
              .fromIsNull()
              .and()
              .toBetween(start, end, includeUpper: false);
        })
        .findAll();
  }

  Future<List<Meeting>?> searchMeetings(String keyword) async {
    if (keyword.isEmpty) {
      return null;
    }
    await asureInstance();

    return await _isar!.meetings
        .filter()
        .titleContains(keyword)
        .or()
        .notesContains(keyword)
        .limit(50)
        .findAll();
  }

  //查找所有重复的会议
  Future<List<Meeting>?> findRecurringMeetings() async {
    await asureInstance();
    return await _isar!.meetings
        .where()
        .filter()
        .recurrenceRuleIsNotNull()
        .and()
        .recurrenceRuleIsNotEmpty()
        .findAll();
  }
}
