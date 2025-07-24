import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as acrylic;
import 'package:flutter/gestures.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await acrylic.Window.initialize();
  await acrylic.Window.setEffect(
    effect: acrylic.WindowEffect.acrylic,
    color: const Color.fromARGB(0, 0, 0, 0),
  );

  runApp(MyApp());

  doWhenWindowReady(() {
    final win = appWindow;
    win.minSize = const Size(600, 400);
    win.alignment = Alignment.center;
    win.show();
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HoveringWindowFrame(),
    );
  }
}

class HoveringWindowFrame extends StatefulWidget {
  @override
  State<HoveringWindowFrame> createState() => _HoveringWindowFrameState();
}

class _HoveringWindowFrameState extends State<HoveringWindowFrame>
    with TickerProviderStateMixin {
  bool _hovering = false;
  late final AnimationController _slideController;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    );
  }

  void _onMouseMove(PointerHoverEvent e) {
    final isInTopArea = e.position.dy <= 35;

    if (isInTopArea && !_hovering) {
      _hovering = true;
      _slideController.forward();
    } else if (!isInTopArea && _hovering) {
      _hovering = false;
      _slideController.reverse();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Listener(
        onPointerHover: _onMouseMove,
        child: Container(
          color: const Color.fromARGB(179, 0, 0, 0), // <-- WINDOW background darkness (adjust here)
          child: Row(
            children: [
              // LEFT SIDE - fully transparent so we see the acrylic behind
              SizedBox(
                width: 200,
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: MoveWindow(),
                      ),
                      Expanded(
                        child: const Center(
                          child: Text(
                            'Left Side',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // RIGHT SIDE - expanded with rounded corners and lighter translucent background
              Expanded(
                child: Column(
                  children: [
                    SizeTransition(
                      sizeFactor: _slideAnimation,
                      axisAlignment: -1.0,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
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
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            color: const Color.fromARGB(51, 0, 0, 0), // <-- RIGHT SIDE panel darkness (adjust here)
                            child: const Center(
                              child: Text(
                                'Right Side',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
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
