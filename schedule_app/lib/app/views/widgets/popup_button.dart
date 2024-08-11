import 'package:flutter/material.dart';

const double _kMenuScreenPadding = 8.0;
typedef PopupBuilder = Widget Function(BuildContext context);

enum PopupDirection { left, top, right, bottom }

enum PopupAlign { start, center, end }

class _PopupRoute<T> extends PopupRoute<T> {
  _PopupRoute(
      {required this.position,
      required this.child,
      this.initialValue,
      this.elevation,
      this.shape,
      this.color,
      required this.align,
      required this.direction});
  final PopupDirection direction;
  final PopupAlign align;
  final RelativeRect position;
  final Widget child;

  final T? initialValue;
  final double? elevation;

  final ShapeBorder? shape;
  final Color? color;

  @override
  Animation<double> createAnimation() {
    return CurvedAnimation(
      parent: super.createAnimation(),
      curve: Curves.linear,
      reverseCurve: const Interval(0.0, 2.0 / 3.0),
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: Builder(
        builder: (BuildContext context) {
          return CustomSingleChildLayout(
            delegate: __PopupRouteLayout(
                position: position,
                padding: mediaQuery.padding,
                align: align,
                direction: direction),
            child: child,
          );
        },
      ),
    );
  }

  @override
  String? get barrierLabel => 'dismiss';
}

class __PopupRouteLayout extends SingleChildLayoutDelegate {
  __PopupRouteLayout(
      {required this.position,
      required this.padding,
      required this.direction,
      required this.align});
  final PopupDirection direction;
  final PopupAlign align;

  final RelativeRect position;

  // The padding of unsafe area.
  EdgeInsets padding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest).deflate(
      const EdgeInsets.all(_kMenuScreenPadding) + padding,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // size: The size of the overlay.
    // childSize: The size of the popup.
    var buttonHeight = size.height - position.top - position.bottom;
    var buttonWidth = size.width - position.left - position.right;
    double x = 0;

    double y = 0;
    var diffHeight = buttonHeight - childSize.height;
    var diffWidth = buttonWidth - childSize.width;
    switch (direction) {
      case PopupDirection.left:
        switch (align) {
          case PopupAlign.start:
            x = position.left - childSize.width;
            y = position.top;
            break;
          case PopupAlign.center:
            x = position.left - childSize.width;
            y = position.top + diffHeight / 2;
            break;
          case PopupAlign.end:
            x = position.left - childSize.width;
            y = size.height - position.bottom - childSize.height;
            break;
        }

        break;
      case PopupDirection.top:
        switch (align) {
          case PopupAlign.start:
            x = position.left;
            y = position.top - childSize.height;
            break;
          case PopupAlign.center:
            x = position.left + diffWidth / 2;
            y = position.top - childSize.height;
            break;
          case PopupAlign.end:
            x = size.width - position.right - childSize.width;
            y = position.top - childSize.height;
            break;
        }

        break;
      case PopupDirection.right:
        switch (align) {
          case PopupAlign.start:
            x = size.width - position.right;
            y = position.top;
            break;
          case PopupAlign.center:
            x = size.width - position.right;
            y = position.top + diffHeight / 2;
            break;
          case PopupAlign.end:
            x = size.width - position.right;
            y = size.height - position.bottom - childSize.height;
            break;
        }

        break;
      case PopupDirection.bottom:
        switch (align) {
          case PopupAlign.start:
            x = position.left;
            y = size.height - position.bottom;
            break;
          case PopupAlign.center:
            x = position.left + diffWidth / 2;
            y = size.height - position.bottom;
            break;
          case PopupAlign.end:
            x = size.width - position.right - childSize.width;
            y = size.height - position.bottom;
            break;
        }

        break;
    }

    // Avoid going outside an area defined as the rectangle 8.0 pixels from the
    // edge of the screen in every direction.
    if (x < _kMenuScreenPadding + padding.left) {
      x = _kMenuScreenPadding + padding.left;
    } else if (x + childSize.width >
        size.width - _kMenuScreenPadding - padding.right) {
      x = size.width - childSize.width - _kMenuScreenPadding - padding.right;
    }
    if (y < _kMenuScreenPadding + padding.top) {
      y = _kMenuScreenPadding + padding.top;
    } else if (y + childSize.height >
        size.height - _kMenuScreenPadding - padding.bottom) {
      y = size.height - padding.bottom - _kMenuScreenPadding - childSize.height;
    }
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(__PopupRouteLayout oldDelegate) {
    return position != oldDelegate.position || padding != oldDelegate.padding;
  }
}

class PopupButton extends StatefulWidget {
  final bool enableFeedback;
  final Widget child;
  final bool enabled;
  final Offset offset;
  final Function? onClose;
  final PopupBuilder builder;
  final PopupDirection direction;
  final BorderRadius? borderRadius;
  final PopupAlign align;
  const PopupButton(
      {Key? key,
      required this.builder,
      required this.direction,
      this.align = PopupAlign.center,
      this.onClose,
      this.offset = Offset.zero,
      this.enabled = true,
      required this.child,
      this.enableFeedback = true,
      this.borderRadius})
      : super(key: key);

  @override
  State<PopupButton> createState() => _PopupButtonState();
}

class _PopupButtonState extends State<PopupButton> {
  void showButtonPopup() {
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    var dx = widget.offset.dx;
    var dy = widget.offset.dy;

    switch (widget.direction) {
      case PopupDirection.left:
        dx = -dx;
        break;
      case PopupDirection.top:
        dy = -dy;
        break;
      case PopupDirection.right:
        break;
      case PopupDirection.bottom:
        break;
    }
    var offset = Offset(dx, dy);
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(offset, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero) + offset,
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    var child = widget.builder(context);
    /*  if (widget.wrapper != null) {
      child = Wrapper(
        child: child,
      );
    } */

    showPopup(
      direction: widget.direction,
      align: widget.align,
      context: context,
      child: child,
      position: position,
    ).then<void>((newValue) {
      if (!mounted) return null;
      widget.onClose?.call(newValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? showButtonPopup : null,
      child: widget.child,
    );
  }
}

Future showPopup(
    {required BuildContext context,
    required RelativeRect position,
    required Widget child,
    bool useRootNavigator = false,
    required PopupDirection direction,
    required PopupAlign align}) {
  final NavigatorState navigator =
      Navigator.of(context, rootNavigator: useRootNavigator);
  return navigator.push(_PopupRoute(
      position: position, child: child, align: align, direction: direction));
}
