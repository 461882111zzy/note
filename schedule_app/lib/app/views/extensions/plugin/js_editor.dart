import 'package:flutter/material.dart';
import 'package:code_editor/code_editor.dart';

typedef OnSave = void Function(String content);

class JsEditor extends StatefulWidget {
  final String code;
  final OnSave onSave;
  const JsEditor({Key? key, required this.code, required this.onSave})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _JsEditorState createState() => _JsEditorState();
}

class _JsEditorState extends State<JsEditor> {
  late EditorModel model;

  @override
  void initState() {
    super.initState();

    List<FileEditor> files = [
      FileEditor(
        name: "index.js",
        language: "javascript",
        code: widget.code,
      ),
    ];

    model = EditorModel(
      files: files, // the files created above
      // you can customize the editor as you want
      styleOptions: EditorModelStyleOptions(
        fontSize: 13,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: CodeEditor(
          model: model, // the model created above
          disableNavigationbar:
              false, // hide the navigation bar ? default is `false`
          // when the user confirms changes in one of the files:
          onSubmit: (String language, String value) {
            print("A file was changed.$value");
            widget.onSave(value);
          },
          // the html code will be auto-formatted
          // after any modification to an HTML file
          formatters: const ["html"],
          textModifier: (String language, String content) {
            print("A file is about to change");

            // transform the code before it is saved
            // if you need to perform some operations on it
            // like your own auto-formatting for example
            return content;
          }),
    );
  }
}
