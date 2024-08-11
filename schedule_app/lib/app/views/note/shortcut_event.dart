import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:dailyflowy/app/views/note/editor_state_extension.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:string_validator/string_validator.dart';
import 'package:tiny_logger/tiny_logger.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'clipboard.dart';
import 'link/image_util.dart';
import 'link/link_preview_block_component.dart';

final CommandShortcutEvent toggleToggleListCommand = CommandShortcutEvent(
  key: 'toggle the toggle list',
  getDescription: () => AppFlowyEditorL10n.current.cmdToggleTodoList,
  command: 'ctrl+enter',
  macOSCommand: 'cmd+enter',
  handler: _toggleToggleListCommandHandler,
);

CommandShortcutEventHandler _toggleToggleListCommandHandler = (editorState) {
  if (PlatformExtension.isMobile) {
    assert(false, 'enter key is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }

  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }
  final nodes = editorState.getNodesInSelection(selection);
  if (nodes.isEmpty || nodes.length > 1) {
    return KeyEventResult.ignored;
  }

  final node = nodes.first;
  if (node.type != ToggleListBlockKeys.type) {
    return KeyEventResult.ignored;
  }

  final collapsed = node.attributes[ToggleListBlockKeys.collapsed] as bool;
  final transaction = editorState.transaction;
  transaction.updateNode(node, {
    ToggleListBlockKeys.collapsed: !collapsed,
  });
  transaction.afterSelection = selection;
  editorState.apply(transaction);
  return KeyEventResult.handled;
};

final CommandShortcutEvent customCutCommand = CommandShortcutEvent(
  key: 'cut the selected content',
  getDescription: () => AppFlowyEditorL10n.current.cmdCutSelection,
  command: 'ctrl+x',
  macOSCommand: 'cmd+x',
  handler: _cutCommandHandler,
);

CommandShortcutEventHandler _cutCommandHandler = (editorState) {
  customCopyCommand.execute(editorState);
  editorState.deleteSelectionIfNeeded();
  return KeyEventResult.handled;
};

class ToggleListBlockKeys {
  const ToggleListBlockKeys._();

  static const String type = 'toggle_list';

  /// The content of a code block.
  ///
  /// The value is a String.
  static const String delta = blockComponentDelta;

  static const String backgroundColor = blockComponentBackgroundColor;

  static const String textDirection = blockComponentTextDirection;

  /// The value is a bool.
  static const String collapsed = 'collapsed';
}

final CommandShortcutEvent customCopyCommand = CommandShortcutEvent(
  key: 'copy the selected content',
  getDescription: () => AppFlowyEditorL10n.current.cmdCopySelection,
  command: 'ctrl+c',
  macOSCommand: 'cmd+c',
  handler: _copyCommandHandler,
);

CommandShortcutEventHandler _copyCommandHandler = (editorState) {
  final selection = editorState.selection?.normalized;
  if (selection == null || selection.isCollapsed) {
    return KeyEventResult.ignored;
  }

  // plain text.
  final text = editorState.getTextInSelection(selection).join('\n');

  final nodes = editorState.getSelectedNodes(selection: selection);
  final document = Document.blank()..insert([0], nodes);

  // in app json
  final inAppJson = jsonEncode(document.toJson());

  // html
  final html = documentToHTML(document);

  () async {
    await ClipboardService.setData(
      ClipboardServiceData(
        plainText: text,
        html: html,
        inAppJson: inAppJson,
      ),
    );
  }();

  return KeyEventResult.handled;
};

final CommandShortcutEvent customPasteCommand = CommandShortcutEvent(
  key: 'paste the content',
  getDescription: () => AppFlowyEditorL10n.current.cmdPasteContent,
  command: 'ctrl+v',
  macOSCommand: 'cmd+v',
  handler: _pasteCommandHandler,
);

CommandShortcutEventHandler _pasteCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }

  // because the event handler is not async, so we need to use wrap the async function here
  () async {
    // dispatch the paste event
    final data = await ClipboardService.getData();
    final inAppJson = data.inAppJson;
    final html = data.html;
    final plainText = data.plainText;
    final image = data.image;

    // paste as link preview
    final result = await _pasteAsLinkPreview(editorState, plainText);
    if (result) {
      return;
    }

    // Order:
    // 1. in app json format
    // 2. html
    // 3. image
    // 4. plain text

    // try to paste the content in order, if any of them is failed, then try the next one
    if (inAppJson != null && inAppJson.isNotEmpty) {
      await editorState.deleteSelectionIfNeeded();
      final result = await editorState.pasteInAppJson(inAppJson);
      if (result) {
        return;
      }
    }

    if (html != null && html.isNotEmpty) {
      await editorState.deleteSelectionIfNeeded();
      final result = await editorState.pasteHtml(html);
      if (result) {
        return;
      }
    }

    if (image != null && image.$2?.isNotEmpty == true) {
      await editorState.deleteSelectionIfNeeded();
      final result = await editorState.pasteImage(image.$1, image.$2!);
      if (result) {
        return;
      }
    }

    if (plainText != null && plainText.isNotEmpty) {
      await editorState.pastePlainText(plainText);
    }
  }();

  return KeyEventResult.handled;
};

Future<bool> _pasteAsLinkPreview(
  EditorState editorState,
  String? text,
) async {
  if (text == null || !isURL(text)) {
    return false;
  }

  final selection = editorState.selection;
  if (selection == null ||
      !selection.isCollapsed ||
      selection.startIndex != 0) {
    return false;
  }

  final node = editorState.getNodeAtPath(selection.start.path);
  if (node == null ||
      node.type != ParagraphBlockKeys.type ||
      node.delta?.toPlainText().isNotEmpty == true) {
    return false;
  }

  final transaction = editorState.transaction;
  transaction.insertNode(
    selection.start.path,
    linkPreviewNode(url: text),
  );
  await editorState.apply(transaction);

  return true;
}

extension PasteFromInAppJson on EditorState {
  Future<bool> pasteInAppJson(String inAppJson) async {
    try {
      final nodes = Document.fromJson(jsonDecode(inAppJson)).root.children;
      if (nodes.isEmpty) {
        return false;
      }
      if (nodes.length == 1) {
        await pasteSingleLineNode(nodes.first);
      } else {
        await pasteMultiLineNodes(nodes.toList());
      }
      return true;
    } catch (e) {
      log.error(
        'Failed to paste in app json: $inAppJson, error: $e',
      );
    }
    return false;
  }
}

extension PasteFromImage on EditorState {
  static final supportedImageFormats = [
    'png',
    'jpeg',
    'gif',
  ];

  Future<bool> pasteImage(String format, Uint8List imageBytes) async {
    if (!supportedImageFormats.contains(format)) {
      return false;
    }

    final context = document.root.context;

    if (context == null) {
      return false;
    }

    final path = await getApplicationSupportDirectory();
    final imagePath = p.join(
      path.path,
      'images',
    );

    try {
      // create the directory if not exists
      final directory = Directory(imagePath);
      if (!directory.existsSync()) {
        await directory.create(recursive: true);
      }
      final copyToPath = p.join(
        imagePath,
        'tmp_${uuid()}.$format',
      );
      await File(copyToPath).writeAsBytes(imageBytes);
      final String? path;

      if (context.mounted) {
        // showSnackBarMessage(
        //   context,
        //   LocaleKeys.document_imageBlock_imageIsUploading.tr(),
        // );
      }

      path = await saveImageToLocalStorage(copyToPath);

      if (path != null) {
        await insertImageNode(path);
      }

      await File(copyToPath).delete();
      return true;
    } catch (e) {
      log.error('cannot copy image file $e');
      if (context.mounted) {
        // showSnackBarMessage(
        //   context,
        //   LocaleKeys.document_imageBlock_error_invalidImage.tr(),
        // );
      }
    }

    return false;
  }
}

String uuid() {
  return const Uuid().v4();
}
