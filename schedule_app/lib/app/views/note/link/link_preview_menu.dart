import 'package:appflowy_editor/appflowy_editor.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../block/block_menu_button.dart';
import '../spacing.dart';
import 'link_preview_block_component.dart';
import 'shared.dart';

class LinkPreviewMenu extends StatefulWidget {
  const LinkPreviewMenu({
    super.key,
    required this.node,
    required this.state,
  });

  final Node node;
  final LinkPreviewBlockComponentState state;

  @override
  State<LinkPreviewMenu> createState() => _LinkPreviewMenuState();
}

class _LinkPreviewMenuState extends State<LinkPreviewMenu> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            spreadRadius: 1,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        children: [
          const HSpace(4),
          MenuBlockButton(
            tooltip: '文本',
            iconData: Icons.text_fields,
            onTap: () => convertUrlPreviewNodeToLink(
              context.read<EditorState>(),
              widget.node,
            ),
          ),
          const HSpace(4),
          MenuBlockButton(
            tooltip: '复制',
            iconData: Icons.copy,
            onTap: copyImageLink,
          ),
          const _Divider(),
          MenuBlockButton(
            tooltip: '删除',
            iconData: Icons.delete,
            onTap: deleteLinkPreviewNode,
          ),
          const HSpace(4),
        ],
      ),
    );
  }

  void copyImageLink() {
    final url = widget.node.attributes[ImageBlockKeys.url];
    if (url != null) {
      Clipboard.setData(ClipboardData(text: url));
      // showSnackBarMessage(
      //   context,
      //   LocaleKeys.document_plugins_urlPreview_copiedToPasteBoard.tr(),
      // );
    }
  }

  Future<void> deleteLinkPreviewNode() async {
    final node = widget.node;
    final editorState = context.read<EditorState>();
    final transaction = editorState.transaction;
    transaction.deleteNode(node);
    transaction.afterSelection = null;
    await editorState.apply(transaction);
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        width: 1,
        color: Colors.grey,
      ),
    );
  }
}
