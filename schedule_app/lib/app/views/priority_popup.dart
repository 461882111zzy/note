import 'package:dailyflowy/app/data/task.dart';
import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:dailyflowy/app/data/task.dart' as task;

import 'colors_util.dart';

class PriorityPopupButton extends StatefulWidget {
  final Widget child;
  final task.Priority initialValue;
  final void Function(task.Priority priority)? onSelected;
  const PriorityPopupButton(
      {super.key,
      required this.child,
      required this.initialValue,
      this.onSelected});

  @override
  State<PriorityPopupButton> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<PriorityPopupButton> {
  final _flyoutController = fluent.FlyoutController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegionBuilder(builder: (context, _) {
      return fluent.FlyoutTarget(
        controller: _flyoutController,
        child: GestureDetector(
            onTap: () {
              _flyoutController.showFlyout(
                  autoModeConfiguration: fluent.FlyoutAutoConfiguration(
                    preferredMode: fluent.FlyoutPlacementMode.bottomCenter,
                  ),
                  barrierDismissible: true,
                  barrierColor: Colors.transparent,
                  shouldConstrainToRootBounds: true,
                  dismissOnPointerMoveAway: false,
                  dismissWithEsc: true,
                  builder: (context) {
                    return fluent.MenuFlyout(
                      items: [
                        _buildItem(task.Priority.low, '低'),
                        _buildItem(task.Priority.medium, '中'),
                        _buildItem(task.Priority.high, '高'),
                      ],
                    );
                  });
            },
            child: widget.child),
      );
    });
  }

  fluent.MenuFlyoutItem _buildItem(Priority priority, String title) {
    return fluent.MenuFlyoutItem(
      leading: Icon(Icons.flag, color: getPriorityColor(priority)),
      text: Text(title,
          style: TextStyle(fontSize: 13, color: getPriorityColor(priority))),
      onPressed: () {
        widget.onSelected?.call(priority);
      },
    );
  }
}
