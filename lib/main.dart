import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as acrylic;

import 'window/window_frame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await acrylic.Window.initialize();
  await acrylic.Window.setEffect(
    effect: acrylic.WindowEffect.acrylic,
    color: const Color.fromARGB(0, 0, 0, 0),
  );

  runApp(const MyApp());

  doWhenWindowReady(() {
    final win = appWindow;
    win.minSize = const Size(600, 400);
    win.alignment = Alignment.center;
    win.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WindowFrame(),
    );
  }
}
