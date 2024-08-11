import 'package:appflowy_editor/appflowy_editor.dart';

import 'link_preview_block_component.dart';

void convertUrlPreviewNodeToLink(EditorState editorState, Node node) {
  assert(node.type == LinkPreviewBlockKeys.type);
  final url = node.attributes[ImageBlockKeys.url];
  final transaction = editorState.transaction;
  transaction
    ..insertNode(node.path, paragraphNode(text: url))
    ..deleteNode(node);
  transaction.afterSelection = Selection.collapsed(
    Position(
      path: node.path,
      offset: url.length,
    ),
  );
  editorState.apply(transaction);
}
