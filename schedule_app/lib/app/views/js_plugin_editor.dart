import 'package:dailyflowy/app/views/extensions/plugin/js_editor.dart';
import 'package:flutter/material.dart';

Future<int?> showPluginDialog(
    BuildContext context, String? code, OnSave onSave) async {
  return await showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
            child: JsPluginEditor(
          code: code,
          onSave: onSave,
        ));
      });
}

class JsPluginEditor extends StatefulWidget {
  final String? code;
  final OnSave onSave;
  const JsPluginEditor({Key? key, this.code, required this.onSave})
      : super(key: key);

  @override
  _JsPluginEditorState createState() => _JsPluginEditorState();
}

class _JsPluginEditorState extends State<JsPluginEditor> {
  @override
  Widget build(BuildContext context) {
    return JsEditor(
      code: widget.code ?? '',
      onSave: (value) {
        widget.onSave(value);
      },
    );
  }
}
