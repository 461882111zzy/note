import 'dart:async';

import 'package:dailyflowy/app/controllers/assets_controller.dart';
import 'package:dailyflowy/app/data/asset.dart';
import 'package:get/get.dart';

import 'extension_base.dart';
import 'extensions.dart';

class ExtensionManager {
  static final ExtensionManager _extensionManager = ExtensionManager();
  static ExtensionManager get instance => _extensionManager;
  final Map<String, ExtensionBase> _extensions = {};
  Future? _initFuture;

  void initialize() async {
    final completer = Completer();
    _initFuture = completer.future;
    final assets = Get.find<AssetsController>();
    final res = await assets.getAssetDatasFilterType(assetTypePlugin, 0, 10);
    res?.forEach((element) {
      final object = _extensions[element.title] ??=
          extensionsFactory[element.title]!.call();
      object.register(element.content ?? '');
      object.onInit();
    });
    completer.complete();
  }

  void clear() {
    _extensions.forEach((key, value) {
      value.dispose();
    });
    _extensions.clear();
  }

  void reload() {
    clear();
    initialize();
  }

  Future<T?> getExtension<T>(String name) async {
    await _initFuture;
    final ext = _extensions[name];
    if (ext == null) return null;
    return ext as T;
  }
}
