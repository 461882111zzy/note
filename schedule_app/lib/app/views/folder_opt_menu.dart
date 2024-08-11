import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';

class WorkSpacePopupButton extends StatefulWidget {
  final void Function(int)? onSelected;
  const WorkSpacePopupButton({super.key, this.onSelected});

  @override
  State<WorkSpacePopupButton> createState() => _WorkSpacePopupButtonState();
}

class _WorkSpacePopupButtonState extends State<WorkSpacePopupButton> {
  final fluent.FlyoutController _flyoutController = fluent.FlyoutController();

  @override
  Widget build(BuildContext context) {
    return fluent.FlyoutTarget(
      controller: _flyoutController,
      child: MouseRegionBuilder(builder: (context, _) {
        return GestureDetector(
          onTap: () {
            _flyoutController.showFlyout(
                autoModeConfiguration: fluent.FlyoutAutoConfiguration(
                  preferredMode: fluent.FlyoutPlacementMode.bottomLeft,
                ),
                barrierDismissible: true,
                dismissOnPointerMoveAway: false,
                dismissWithEsc: true,
                barrierColor: Colors.transparent,
                builder: (context) {
                  return fluent.MenuFlyout(
                    items: [
                      fluent.MenuFlyoutItem(
                        leading: const Icon(Icons.edit),
                        text: const Text('重命名'),
                        onPressed: () {
                          widget.onSelected?.call(0);
                        },
                      ),
                      fluent.MenuFlyoutItem(
                        leading: const Icon(Icons.delete),
                        text: const Text('删除'),
                        onPressed: () {
                          widget.onSelected?.call(1);
                        },
                      ),
                    ],
                  );
                });
          },
          child: const Icon(
            Icons.more_horiz_rounded,
            size: 15,
          ),
        );
      }),
    );
  }
}

class FolderPopupButton extends StatefulWidget {
  final void Function(int)? onSelected;
  const FolderPopupButton({super.key, this.onSelected});

  @override
  State<FolderPopupButton> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<FolderPopupButton> {
  final fluent.FlyoutController _flyoutController = fluent.FlyoutController();
  @override
  Widget build(BuildContext context) {
    return fluent.FlyoutTarget(
      controller: _flyoutController,
      child: MouseRegionBuilder(builder: (context, _) {
        return GestureDetector(
          onTap: () {
            _flyoutController.showFlyout(
                autoModeConfiguration: fluent.FlyoutAutoConfiguration(
                  preferredMode: fluent.FlyoutPlacementMode.bottomLeft,
                ),
                barrierDismissible: true,
                dismissOnPointerMoveAway: false,
                dismissWithEsc: true,
                barrierColor: Colors.transparent,
                builder: (context) {
                  return fluent.MenuFlyout(
                    items: [
                      fluent.MenuFlyoutItem(
                        leading: const Icon(Icons.edit),
                        text: const Text('重命名'),
                        onPressed: () {
                          widget.onSelected?.call(0);
                        },
                      ),
                      fluent.MenuFlyoutItem(
                        leading: const Icon(Icons.delete),
                        text: const Text('删除'),
                        onPressed: () {
                          widget.onSelected?.call(1);
                        },
                      ),
                      fluent.MenuFlyoutItem(
                        leading: const Icon(Icons.add),
                        text: const Text('添加任务'),
                        onPressed: () {
                          widget.onSelected?.call(2);
                        },
                      ),
                    ],
                  );
                });
          },
          child: const Icon(
            Icons.more_horiz_rounded,
            size: 15,
          ),
        );
      }),
    );
  }
}
