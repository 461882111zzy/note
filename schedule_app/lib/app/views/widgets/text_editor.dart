import 'package:fluent_ui/fluent_ui.dart' as ui;
import 'package:flutter/cupertino.dart';

class TextEditior extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final double fontSize;
  final Color? fontColor;
  final int? maxLength;
  const TextEditior(
      {super.key,
      required this.controller,
      required this.placeholder,
      this.fontSize = 18.0,
      this.maxLength,
      this.fontColor});

  @override
  Widget build(BuildContext context) {
    final theme = ui.FluentTheme.of(context);
    return CupertinoTextField(
      controller: controller,
      padding: const EdgeInsets.only(left: 0, right: 0, top: 3, bottom: 3),
      style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: fontColor ?? theme.typography.subtitle!.color),
      minLines: 1,
      maxLines: 1,
      maxLength: maxLength,
      showCursor: true,
      textAlignVertical: TextAlignVertical.top,
      cursorWidth: 1,
      textAlign: TextAlign.left,
      cursorColor: theme.accentColor,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide.none,
        ),
      ),
      placeholder: placeholder,
      placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey),
    );
  }
}
