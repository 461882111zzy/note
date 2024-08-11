import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:dailyflowy/app/controllers/utils.dart';

// This function converts Quill content to plain text
String? toPlainText(String? content, [limit = 50]) {
  if (content == null || content == '') {
    return '没有任务描述';
  }
  final quillDeltaEncoder = QuillDeltaEncoder();
  Document doc = Document.blank(withInitialText: true);
  dynamic data;
  try {
    data = jsonDecode(content);
  } catch (e) {
    return content;
  }

  try {
    doc = Document.fromJson(data);
  } catch (e) {
    doc = quillDeltaEncoder.convert(Delta.fromJson(data));
  }

  String text = doc.sumary(maxLength: limit);
  if (text == '') {
    return '没有任务描述';
  }
  return text;
}
