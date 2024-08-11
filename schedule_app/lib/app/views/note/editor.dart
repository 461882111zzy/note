import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:dailyflowy/app/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

import 'link/link_preview_block_component.dart';
import 'link/link_preview_cache.dart';
import 'link/link_preview_menu.dart';
import 'link/custom_link_preview.dart';
import 'shortcut_event.dart';

class AppFlowyEditorWidget extends StatelessWidget {
  final EditorState editorState;
  final FocusNode? focusNode;
  const AppFlowyEditorWidget({
    super.key,
    required this.editorState,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingToolbar(
      editorScrollController: EditorScrollController(editorState: editorState),
      items: [
        paragraphItem,
        ...headingItems,
        ...markdownFormatItems,
        quoteItem,
        bulletedListItem,
        numberedListItem,
        linkItem,
        buildTextColorItem(),
        buildHighlightColorItem(),
      ],
      editorState: editorState,
      textDirection: null,
      child: _buildDesktopEditor(context, editorState),
    );
  }

  Widget _buildDesktopEditor(
    BuildContext context,
    EditorState editorState,
  ) {
    final customBlockComponentBuilders = {
      ...customBlockComponentBuilderMap,
    };

    final theme = fluent.FluentTheme.of(context);

    return Theme(
      data: theme.toThemeData(),
      child: AppFlowyEditor(
        editorState: editorState,
        enableAutoComplete: true,
        autoFocus: true,
        focusNode: focusNode,
        editorStyle: _buildDesktopEditorStyle(context),
        blockComponentBuilders: customBlockComponentBuilders,
        commandShortcutEvents: [
          toggleToggleListCommand,
          customCopyCommand,
          customPasteCommand,
          customCutCommand,
          ...standardCommandShortcutEvents,
          ...findAndReplaceCommands(
            context: context,
            localizations: FindReplaceLocalizations(
              find: '查找',
              previousMatch: '上一个',
              nextMatch: '下一个',
              close: '关闭',
              replace: '替换',
              replaceAll: '替换全部',
              noResult: '无结果',
            ),
          ),
        ],
        characterShortcutEvents: standardCharacterShortcutEvents,
      ),
    );
  }
}

const standardBlockComponentConfiguration = BlockComponentConfiguration();

final Map<String, BlockComponentBuilder> customBlockComponentBuilderMap = {
  PageBlockKeys.type: PageBlockComponentBuilder(),
  ParagraphBlockKeys.type: ParagraphBlockComponentBuilder(
    showPlaceholder: (editorState, node) {
      final showPlaceholder = editorState.document.isEmpty ||
          editorState.selection != null &&
              (editorState.selection!.isSingle &&
                  editorState.selection!.start.path.equals(node.path));
      return showPlaceholder;
    },
    configuration: standardBlockComponentConfiguration.copyWith(
      placeholderText: (_) => PlatformExtension.isDesktopOrWeb
          ? AppFlowyEditorL10n.current.slashPlaceHolder
          : ' ',
    ),
  ),
  TodoListBlockKeys.type: TodoListBlockComponentBuilder(
    configuration: standardBlockComponentConfiguration.copyWith(
      placeholderText: (_) => AppFlowyEditorL10n.current.toDoPlaceholder,
    ),
    toggleChildrenTriggers: [
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.shiftLeft,
      LogicalKeyboardKey.shiftRight,
    ],
  ),
  BulletedListBlockKeys.type: BulletedListBlockComponentBuilder(
    configuration: standardBlockComponentConfiguration.copyWith(
      placeholderText: (_) => AppFlowyEditorL10n.current.listItemPlaceholder,
    ),
  ),
  NumberedListBlockKeys.type: NumberedListBlockComponentBuilder(
    configuration: standardBlockComponentConfiguration.copyWith(
      placeholderText: (_) => AppFlowyEditorL10n.current.listItemPlaceholder,
    ),
  ),
  QuoteBlockKeys.type: QuoteBlockComponentBuilder(
    configuration: standardBlockComponentConfiguration.copyWith(
      placeholderText: (_) => AppFlowyEditorL10n.current.quote,
    ),
  ),
  HeadingBlockKeys.type: HeadingBlockComponentBuilder(
    configuration: standardBlockComponentConfiguration.copyWith(
      placeholderText: (node) =>
          'Heading ${node.attributes[HeadingBlockKeys.level]}',
    ),
  ),
  ImageBlockKeys.type: ImageBlockComponentBuilder(),
  DividerBlockKeys.type: DividerBlockComponentBuilder(
    configuration: standardBlockComponentConfiguration.copyWith(
      padding: (node) => const EdgeInsets.symmetric(vertical: 8.0),
    ),
  ),
  TableBlockKeys.type: TableBlockComponentBuilder(
    tableStyle: const TableStyle(borderWidth: 1),
  ),
  TableCellBlockKeys.type: TableCellBlockComponentBuilder(),
  LinkPreviewBlockKeys.type: LinkPreviewBlockComponentBuilder(
    cache: LinkPreviewDataCache(),
    showMenu: true,
    menuBuilder: (context, node, state) => Positioned(
      top: 10,
      right: 0,
      child: LinkPreviewMenu(node: node, state: state),
    ),
    builder: (_, node, url, title, description, imageUrl) =>
        CustomLinkPreviewWidget(
      node: node,
      url: url,
      title: title,
      description: description,
      imageUrl: imageUrl,
    ),
  ),
};

EditorStyle _buildDesktopEditorStyle(BuildContext context) {
  final theme = fluent.FluentTheme.of(context);
  return EditorStyle.desktop(
    cursorWidth: 1.0,
    cursorColor: theme.accentColor,
    selectionColor: theme.selectionColor.withOpacity(0.7),
    textStyleConfiguration: TextStyleConfiguration(
      text: theme.typography.body!,
      code: GoogleFonts.architectsDaughter(),
      bold: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
      ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 0.0),
  );
}
