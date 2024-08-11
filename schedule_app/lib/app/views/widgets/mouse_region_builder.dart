import 'package:flutter/material.dart';

class MouseRegionBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool entered) builder;
  const MouseRegionBuilder({super.key, required this.builder});

  @override
  State<MouseRegionBuilder> createState() => _MouseRegionBuilderState();
}

class _MouseRegionBuilderState extends State<MouseRegionBuilder> {
  bool _enterIn = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (val) {
        setState(() {
          _enterIn = true;
        });
      },
      onExit: (val) {
        setState(() {
          _enterIn = false;
        });
      },
      child: widget.builder(context, _enterIn),
    );
  }
}
