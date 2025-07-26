import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'window_buttons.dart';

class CustomTitleBar extends StatelessWidget {
  final Animation<double> slideAnimation;
  final Animation<double> fadeAnimation;

  const CustomTitleBar({
    super.key,
    required this.slideAnimation,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: slideAnimation,
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: WindowTitleBarBox(
          child: Container(
            height: 40,
            color: Colors.transparent,
            child: Row(
              children: [
                Expanded(child: MoveWindow()),
                WindowButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
