import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

typedef OnExpandChanged = void Function(Node node, bool isExpanded);

class Node<T> {
  Node({
    required this.data,
    Iterable<Node>? children,
    this.onExpandChanged,
  }) : _children = <Node>[] {
    if (children == null) return;

    for (final Node child in children) {
      child._parent = this;
      _children.add(child);
    }
  }

  T data;

  bool _isExpanded = false;

  final OnExpandChanged? onExpandChanged;

  set isExpanded(bool value) {
    _isExpanded = value;
    onExpandChanged?.call(this, value);
  }

  bool get isExpanded => _isExpanded;

  final List<Node> _children;

  Iterable<Node> get children => _children;
  bool get isLeaf => _children.isEmpty;

  void cleanChildren() {
    _children.clear();
  }

  void addChildren(Node node) {
    _children.add(node);
  }

  void setParent(Node node) {
    _parent = node;
  }

  void update(T data) {
    this.data = data;
  }

  Node? get parent => _parent;
  Node? _parent;

  int get index => _parent?._children.indexOf(this) ?? -1;

  void insertChild(int index, Node node) {
    if (node._parent == this && node.index < index) {
      index--;
    }
    if (index < 0) {
      index = 0;
    }
    node
      .._parent?._children.remove(node)
      .._parent = this;

    _children.insert(index, node);
  }
}

enum DropPositon {
  none,
  whenAbove,
  whenInside,
  whenBelow,
}

extension on TreeDragAndDropDetails<Node> {
  /// Splits the target node's height in three and checks the vertical offset
  /// of the dragging node, applying the appropriate callback.
  T mapDropPosition<T>({
    required T Function() whenAbove,
    required T Function() whenInside,
    required T Function() whenBelow,
  }) {
    final double oneThirdOfTotalHeight = targetBounds.height * 0.3;
    final double pointerVerticalOffset = dropPosition.dy;

    if (pointerVerticalOffset < oneThirdOfTotalHeight) {
      return whenAbove();
    } else if (pointerVerticalOffset < oneThirdOfTotalHeight * 2) {
      return whenInside();
    } else {
      return whenBelow();
    }
  }
}

class TreeControllerEx extends TreeController<Node> {
  TreeControllerEx(
      {required super.roots,
      required super.childrenProvider,
      required super.parentProvider});
  @override
  bool getExpansionState(Node node) => node.isExpanded;

  @override
  void setExpansionState(Node node, bool expanded) {
    node.isExpanded = expanded;
  }
}

class DragAndDropTreeView extends StatefulWidget {
  final Node root;
  final TreeController<Node> treeController;
  final Widget Function(Node node) nodeWidgetBuilder;
  final bool Function(Node from, Node target, DropPositon dropPositon)
      canAccept;
  final void Function(Node from, Node target, DropPositon dropPositon)
      onNodeAccepted;
  const DragAndDropTreeView(
      {super.key,
      required this.root,
      required this.treeController,
      required this.nodeWidgetBuilder,
      required this.canAccept,
      required this.onNodeAccepted});

  @override
  State<DragAndDropTreeView> createState() => _DragAndDropTreeViewState();
}

class _DragAndDropTreeViewState extends State<DragAndDropTreeView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onNodeAccepted(TreeDragAndDropDetails<Node> details) {
    Node? newParent;
    int newIndex = 0;
    bool isAccept = false;
    DropPositon dropPositon = DropPositon.none;
    details.mapDropPosition(
      whenAbove: () {
        if (widget.canAccept(
            details.draggedNode, details.targetNode, DropPositon.whenAbove)) {
          // Insert the dragged node as the previous sibling of the target node.
          newParent = details.targetNode.parent;
          newIndex = details.targetNode.index;

          isAccept = true;
          dropPositon = DropPositon.whenAbove;
        }
      },
      whenInside: () {
        if (widget.canAccept(
            details.draggedNode, details.targetNode, DropPositon.whenInside)) {
          // Insert the dragged node as the last child of the target node.
          newParent = details.targetNode;
          newIndex = details.targetNode.children.length;

          // Ensure that the dragged node is visible after reordering.
          widget.treeController.setExpansionState(details.targetNode, true);

          isAccept = true;
          dropPositon = DropPositon.whenInside;
        }
      },
      whenBelow: () {
        if (widget.canAccept(
            details.draggedNode, details.targetNode, DropPositon.whenBelow)) {
          // Insert the dragged node as the next sibling of the target node.
          newParent = details.targetNode.parent;
          newIndex = details.targetNode.index + 1;

          isAccept = true;
          dropPositon = DropPositon.whenBelow;
        }
      },
    );

    if (isAccept) {
      (newParent ?? widget.root).insertChild(newIndex, details.draggedNode);

      // Rebuild the tree to show the reordered node in its new vicinity.
      widget.treeController.rebuild();

      widget.onNodeAccepted(
          details.draggedNode, details.targetNode, dropPositon);
    }
  }

  @override
  Widget build(BuildContext context) {
    final IndentGuide indentGuide = DefaultIndentGuide.of(context);
    final BorderSide borderSide = BorderSide(
      color: Theme.of(context).colorScheme.outline,
      width: indentGuide is AbstractLineGuide ? indentGuide.thickness : 1.0,
    );

    return AnimatedTreeView<Node>(
      treeController: widget.treeController,
      padding: EdgeInsets.zero,
      nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
        return DragAndDropTreeTile(
          entry: entry,
          borderSide: borderSide,
          onNodeAccepted: onNodeAccepted,
          nodeWidgetBuilder: widget.nodeWidgetBuilder,
          onFolderPressed: () =>
              widget.treeController.toggleExpansion(entry.node),
        );
      },
      duration: const Duration(milliseconds: 200),
    );
  }
}

class DragAndDropTreeTile extends StatelessWidget {
  const DragAndDropTreeTile({
    super.key,
    required this.entry,
    required this.nodeWidgetBuilder,
    required this.onNodeAccepted,
    this.borderSide = BorderSide.none,
    this.onFolderPressed,
  });

  final TreeEntry<Node> entry;
  final TreeDragTargetNodeAccepted<Node> onNodeAccepted;
  final BorderSide borderSide;
  final VoidCallback? onFolderPressed;
  final Widget Function(Node node) nodeWidgetBuilder;

  @override
  Widget build(BuildContext context) {
    return TreeDragTarget<Node>(
      node: entry.node,
      onNodeAccepted: onNodeAccepted,
      builder: (BuildContext context, TreeDragAndDropDetails<Node>? details) {
        Decoration? decoration;

        if (details != null) {
          // Add a border to indicate in which portion of the target's height
          // the dragging node will be inserted.
          decoration = BoxDecoration(
            border: details.mapDropPosition(
              whenAbove: () => Border(top: borderSide),
              whenInside: () => Border.fromBorderSide(borderSide),
              whenBelow: () => Border(bottom: borderSide),
            ),
          );
        }

        return TreeDraggable<Node>(
          node: entry.node,
          longPressDelay: const Duration(milliseconds: 400),
          collapseOnDragStart: false,
          childWhenDragging: Opacity(
            opacity: .5,
            child: IgnorePointer(
              child: TreeTile(
                entry: entry,
                nodeWidgetBuilder: nodeWidgetBuilder,
              ),
            ),
          ),
          feedback: IntrinsicWidth(
            child: Material(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: TreeTile(
                  entry: entry,
                  nodeWidgetBuilder: nodeWidgetBuilder,
                  showIndentation: false,
                  onFolderPressed: () {},
                ),
              ),
            ),
          ),
          child: TreeTile(
            entry: entry,
            nodeWidgetBuilder: nodeWidgetBuilder,
            onFolderPressed: entry.node.isLeaf ? null : onFolderPressed,
            decoration: decoration,
          ),
        );
      },
    );
  }
}

class TreeTile extends StatelessWidget {
  const TreeTile({
    super.key,
    required this.entry,
    required this.nodeWidgetBuilder,
    this.onFolderPressed,
    this.decoration,
    this.showIndentation = true,
  });

  final Widget Function(Node node) nodeWidgetBuilder;
  final TreeEntry<Node> entry;
  final VoidCallback? onFolderPressed;
  final Decoration? decoration;
  final bool showIndentation;

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      children: [
        if (!entry.node.isLeaf)
          FolderButton(
            color: Colors.grey,
            openedIcon: const Icon(
              Icons.arrow_drop_down,
            ),
            closedIcon: const Icon(
              Icons.arrow_right,
            ),
            iconSize: 20,
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.task_alt_outlined,
              color: Colors.blue,
            ),
            splashRadius: 1,
            splashColor: Colors.transparent,
            constraints: const BoxConstraints(minHeight: 20, minWidth: 20),
            enableFeedback: false,
            isOpen: entry.node.isLeaf ? null : entry.isExpanded,
            onPressed: onFolderPressed,
          ),
        Expanded(
            child: GestureDetector(
              onTap: onFolderPressed,
              child: Container(
                        margin: const EdgeInsets.only(
                top: 2.5, bottom: 2.5, left: 2.5, right: 2.5),
                        child: nodeWidgetBuilder(entry.node),
                      ),
            )),
      ],
    );

    if (decoration != null) {
      content = DecoratedBox(
        decoration: decoration!,
        child: content,
      );
    }

    if (showIndentation) {
      return TreeIndentation(
        entry: entry,
        guide: const IndentGuide(indent: 15),
        child: content,
      );
    }

    return content;
  }
}
