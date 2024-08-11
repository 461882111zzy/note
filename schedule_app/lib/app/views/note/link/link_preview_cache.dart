import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'link_preview_block_component.dart';

class LinkPreviewDataCache implements LinkPreviewDataCacheInterface {
  @override
  Future<LinkPreviewData?> get(String url) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final value = sharedPreferences.getString(url);
    if (value != null) {
      return LinkPreviewData.fromJson(jsonDecode(value));
    }
    return null;
  }

  @override
  Future<void> set(String url, LinkPreviewData data) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(url, jsonEncode(data.toJson()));
  }
}
