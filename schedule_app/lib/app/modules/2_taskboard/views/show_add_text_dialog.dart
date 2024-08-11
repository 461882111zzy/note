import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<String?> showAddTextDialog(BuildContext context,
    {String initContent = ''}) async {
  return await fluent.showDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black12,
      builder: (context) {
        return InputStringDialog(initContent: initContent);
      });
}

class InputStringDialog extends StatefulWidget {
  final String? initContent;
  const InputStringDialog({super.key, this.initContent});

  @override
  State<InputStringDialog> createState() => _InputStringDialogState();
}

class _InputStringDialogState extends State<InputStringDialog> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    _textEditingController.text = widget.initContent ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = fluent.FluentTheme.of(context);
    return Dialog(
      child: fluent.FlyoutContent(
        padding: fluent.EdgeInsets.zero,
        child: SizedBox(
            width: 300,
            height: 90,
            child: TextField(
                onEditingComplete: () {
                  Navigator.of(context).pop(_textEditingController.text);
                },
                controller: _textEditingController,
                maxLength: 40,
                decoration: InputDecoration(
                  hintText: '请输入',
                  hintStyle:
                      theme.typography.body!.copyWith(color: Colors.grey),
                )).marginOnly(left: 10, right: 10)),
      ),
    );
  }
}
