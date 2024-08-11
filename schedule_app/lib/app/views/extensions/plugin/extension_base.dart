import 'package:dailyflowy/app/views/extensions/plugin/js_plugin.dart';
import 'package:tuple/tuple.dart';
import 'package:tiny_logger/tiny_logger.dart';

abstract class ExtensionBase {
  final List<Tuple2<String, JSPlugin>> _plugins = [];
  void register(String pluginCode) {
    _plugins.add(Tuple2<String, JSPlugin>(pluginCode, JSPlugin()));
  }

  String name();

  void onInit();

  Map<String, dynamic Function(dynamic)> getOnMessageHandlers();

  List<Future<String>> run() {
    final handlers = getOnMessageHandlers();
    handlers['log'] = onLog;
    List<Future<String>> res = [];
    for (var element in _plugins) {
      handlers.forEach((key, value) {
        element.item2.registerOnMessage(key, value);
      });
      res.add(element.item2.evalJS(element.item1));
    }

    return res;
  }

  dynamic onLog(dynamic logString) {
    log.warn(logString);
  }

  void dispose() {
    for (var element in _plugins) {
      element.item2.dispose();
    }
  }

  void sendMessage(String channelName, List<String> args) {
    for (var element in _plugins) {
      element.item2.sendMessage(channelName, args);
    }
  }
}
