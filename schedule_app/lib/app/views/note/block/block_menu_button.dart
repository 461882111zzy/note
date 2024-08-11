import 'package:flutter/material.dart';

class MenuBlockButton extends StatelessWidget {
  const MenuBlockButton({
    super.key,
    required this.tooltip,
    required this.iconData,
    this.onTap,
  });

  final VoidCallback? onTap;
  final String tooltip;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Tooltip(
        message: tooltip,
        child: Icon(
          iconData,
          size: 16,
        ),
      ),
    );
  }
}
