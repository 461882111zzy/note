import 'package:dio/dio.dart';
import 'package:get/get.dart';

enum DayType { vacation, remark, none }

class Holiday {
  late DateTime day;
  late DayType dayType;
  late String? name;
}

class HolidayController extends GetxController {
  late Map<DateTime, Holiday> _holidaysMap;
  final updated = 0.obs;
  @override
  void onInit() {
    super.onInit();
    _holidaysMap = {};
    initHoliday();
  }

  void initHoliday() async {
    final now = DateTime.now();
    _holidaysMap.addAll(await _fetchHolidayFromApi(now.year));
    _holidaysMap.addAll(await _fetchHolidayFromApi(now.year + 1));
    updated.value = DateTime.now().millisecondsSinceEpoch;
    updated.refresh();
  }

  // 从 https://timor.tech/api/holiday/year/2024/拉取节假日列表
  //返回数据如下：

  Future<Map<DateTime, Holiday>> _fetchHolidayFromApi(int year) async {
    final Map<DateTime, Holiday> resHolidaysMap = {};
    try {
      final res = await Dio().get('https://timor.tech/api/holiday/year/$year/');
      // {"code":0,"holiday":{"01-01":{"holiday":true,"name":"元旦","wage":3,"date":"2024-01-01","rest":1}}}
      final holidayMap = res.data['holiday'] as Map<String, dynamic>;
      holidayMap.forEach((key, value) {
        final holiday = Holiday();
        holiday.day = DateTime.parse(value['date']);
        final name = value['name'];
        holiday.name = null;
        if (name.contains('补班') || name.contains('调休')) {
          holiday.name = null;
        } else {
          holiday.name = name;
        }
        holiday.dayType = DayType.none;
        if (value['holiday'] == true) {
          holiday.dayType = DayType.vacation;
        } else if (value['holiday'] == false) {
          holiday.dayType = DayType.remark;
        }
        resHolidaysMap[holiday.day] = holiday;
      });
    } catch (e) {}

    return resHolidaysMap;
  }

  Holiday? findHolidayInfo(DateTime dateTime) {
    final formatDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    return _holidaysMap[formatDate];
  }
}
