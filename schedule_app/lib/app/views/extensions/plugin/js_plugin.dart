import 'dart:convert';

import 'package:flutter_js/extensions/fetch.dart';
import 'package:flutter_js/extensions/xhr.dart';
import 'package:flutter_js/flutter_js.dart';

class JSPlugin {
  late JavascriptRuntime javascriptRuntime;

  JSPlugin() {
    javascriptRuntime = getJavascriptRuntime();
    _init();
  }

  void _init() {
    javascriptRuntime.enableHandlePromises();
    javascriptRuntime.enableFetch();
    javascriptRuntime.enableXhr();
  }

  void dispose() {
    javascriptRuntime.dispose();
  }

  Future<String> evalJS(String js) async {
    JsEvalResult jsResult = await javascriptRuntime.evaluateAsync(
      js,
      sourceUrl: 'script.js',
    );
    javascriptRuntime.executePendingJob();
    JsEvalResult asyncResult = await javascriptRuntime.handlePromise(jsResult);
    return asyncResult.stringResult;
  }

  void registerOnMessage(String jsFun, dynamic Function(dynamic args) fun) {
    javascriptRuntime.onMessage(jsFun, (args) {
      return fun(args);
    });
  }

  void sendMessage(String channelName, List<String> args) async {
    //  javascriptRuntime.sendMessage(channelName: channelName, args: args);
    await evalJS(
        "DART_TO_QUICKJS_CHANNEL_sendMessage('$channelName', '${jsonEncode(args)}');");
  }
}
