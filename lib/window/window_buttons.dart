import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

class WindowButtons extends StatelessWidget {
  WindowButtons({super.key});

  final buttonColors = WindowButtonColors(
    iconNormal: Colors.white,
    mouseOver: const Color.fromARGB(77, 255, 255, 255),
    mouseDown: const Color.fromARGB(127, 255, 255, 255),
    iconMouseOver: Colors.white,
    iconMouseDown: Colors.white,
  );

  final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: Colors.white,
    iconMouseOver: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
