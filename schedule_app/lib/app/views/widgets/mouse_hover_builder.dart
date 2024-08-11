import 'package:flutter/material.dart';

class MouseHoverBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool entered) builder;
  const MouseHoverBuilder({super.key, required this.builder});

  @override
  State<MouseHoverBuilder> createState() => _MouseHoverBuilderState();
}

class _MouseHoverBuilderState extends State<MouseHoverBuilder> {
  bool _enterIn = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (val) {
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
