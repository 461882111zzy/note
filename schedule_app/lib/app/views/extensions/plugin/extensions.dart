import 'extension_base.dart';
import 'schedule_extension.dart';

enum ExtensionName {
  schedule('schedule');

  final String value;
  const ExtensionName(this.value);
}

final Map<String, ExtensionBase Function()> extensionsFactory = {
  ExtensionName.schedule.value: ScheduleExtension.creator()
};
