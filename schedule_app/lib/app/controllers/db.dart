import 'package:dailyflowy/app/data/asset.dart';
import 'package:dailyflowy/app/data/docs.dart';
import 'package:dailyflowy/app/data/line_up.dart';
import 'package:dailyflowy/app/data/meeting.dart';
import 'package:dailyflowy/app/data/message.dart';
import 'package:dailyflowy/app/data/task.dart';
import 'package:dailyflowy/app/data/workspace.dart';
import 'package:isar/isar.dart';

class Db {
  static Isar? _isar;
  static Future<Isar>? _isarFuture;
  static Future<Isar> get() async {
    _isarFuture ??= Isar.open([
      WorkSpaceDataSchema,
      TaskSchema,
      MessageSchema,
      MeetingSchema,
      DocDataSchema,
      LineUpSchema,
      AssetDataSchema,
    ]);
    _isar ??= await _isarFuture;
    return _isar!;
  }
}

mixin IsarMixin {
  Isar? isar;

  late Future<Isar> _isarFuture;

  void initIsar() async {
    _isarFuture = Db.get();
  }

  Future<void> asureInstance() async {
    isar ??= await _isarFuture;
  }
}
