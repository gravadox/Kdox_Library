import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'left_panel.dart';
import 'right_panel.dart';
import 'custom_title_bar.dart';

class WindowFrame extends StatefulWidget {
  const WindowFrame({super.key});

  @override
  State<WindowFrame> createState() => _WindowFrameState();
}

class _WindowFrameState extends State<WindowFrame> with TickerProviderStateMixin {
  bool _hovering = false;
  late final AnimationController _slideController;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  
  // Left panel animation controller
  late final AnimationController _leftPanelController;
  late final Animation<double> _leftPanelAnimation;
  bool _isLeftPanelVisible = true;
  static const double _leftPanelWidth = 200.0;

  // Key for accessing LeftPanel methods - now using the public state class
  final GlobalKey<LeftPanelState> _leftPanelKey = GlobalKey<LeftPanelState>();

  // Action handlers
  VoidCallback? _zoomIn;
  VoidCallback? _zoomOut;
  VoidCallback? _openFile;
  int _zoomPercent = 100;

  // Search & page handlers
  void Function(String text)? _onSearch;
  VoidCallback? _onNextSearch;
  VoidCallback? _onPrevSearch;
  void Function(int page)? _onJumpToPage;
  int _currentPage = 1;
  int _totalPages = 1;
  String _currentFileName = 'No file loaded';

  // Search result state stored here separately
  int _searchCurrentIndex = 0;
  int _searchTotalCount = 0;

  // Page layout mode state
  PdfPageLayoutMode _pageLayoutMode = PdfPageLayoutMode.continuous;

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

    // Initialize left panel animation controller
    _leftPanelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _leftPanelAnimation = CurvedAnimation(
      parent: _leftPanelController,
      curve: Curves.easeInOut,
    );
    
    // Start with panel visible
    _leftPanelController.value = 1.0;

    // Listen for keyboard shortcuts using ServicesBinding
    ServicesBinding.instance.keyboard.addHandler(_handleRawKeyEvent);
  }

  void _onRightPanelMouseMove(PointerHoverEvent e) {
    final isInTopArea = e.position.dy <= 35;
    if (isInTopArea && !_hovering) {
      _hovering = true;
      _slideController.forward();
    } else if (!isInTopArea && _hovering) {
      _hovering = false;
      _slideController.reverse();
    }
  }

  void _toggleLeftPanel() {
    setState(() {
      _isLeftPanelVisible = !_isLeftPanelVisible;
    });
    
    if (_isLeftPanelVisible) {
      _leftPanelController.forward();
    } else {
      _leftPanelController.reverse();
    }
  }

  void _hideLeftPanel() {
    if (_isLeftPanelVisible) {
      setState(() {
        _isLeftPanelVisible = false;
      });
      _leftPanelController.reverse();
    }
  }

  void _showLeftPanelAndFocusSearch() {
    if (!_isLeftPanelVisible) {
      setState(() {
        _isLeftPanelVisible = true;
      });
      _leftPanelController.forward().then((_) {
        // Add a small delay to ensure the widget is fully settled
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            _leftPanelKey.currentState?.focusSearchField();
          }
        });
      });
    } else {
      // Panel is already visible, just focus the search field
      _leftPanelKey.currentState?.focusSearchField();
    }
  }

  bool _handleRawKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final isAltPressed = HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.altLeft) ||
                          HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.altRight);
      
      final isCtrlPressed = HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) ||
                           HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlRight);
      
      if (isAltPressed && event.logicalKey == LogicalKeyboardKey.keyS) {
        _toggleLeftPanel();
        return true;
      }
      
      if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyF) {
        _showLeftPanelAndFocusSearch();
        return true;
      }

      if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyS) {
        _toggleLeftPanel();
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_handleRawKeyEvent);
    _slideController.dispose();
    _leftPanelController.dispose();
    super.dispose();
  }

  void _handleFileNameChanged(String fileName) {
    setState(() {
      _currentFileName = fileName;
    });
  }

  // This matches the signature RightPanel expects (10 parameters)
  void _handleActions(
    VoidCallback zoomIn,
    VoidCallback zoomOut,
    VoidCallback openFile,
    int zoomPercent,
    void Function(String text) onSearchTextChanged,
    VoidCallback onSearchNext,
    VoidCallback onSearchPrevious,
    void Function(int page) onJumpToPage,
    int currentPage,
    int totalPages,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _zoomIn = zoomIn;
        _zoomOut = zoomOut;
        _openFile = openFile;
        _zoomPercent = zoomPercent;
        _onSearch = onSearchTextChanged;
        _onNextSearch = onSearchNext;
        _onPrevSearch = onSearchPrevious;
        _onJumpToPage = onJumpToPage;
        _currentPage = currentPage;
        _totalPages = totalPages;
      });
    });
  }

  // Call this from RightPanel whenever search results update
  void _updateSearchResultCounts(int currentIndex, int totalCount) {
    setState(() {
      _searchCurrentIndex = currentIndex;
      _searchTotalCount = totalCount;
    });
  }

  // Handlers for layout mode buttons
  void _setSinglePageLayout() {
    setState(() {
      _pageLayoutMode = PdfPageLayoutMode.single;
    });
  }

  void _setContinuousLayout() {
    setState(() {
      _pageLayoutMode = PdfPageLayoutMode.continuous;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: const Color.fromARGB(179, 0, 0, 0),
        child: Stack(
          children: [
            // Right panel (positioned to account for left panel)
            AnimatedBuilder(
              animation: _leftPanelAnimation,
              builder: (context, child) {
                final leftOffset = _leftPanelWidth * _leftPanelAnimation.value;
                return Positioned(
                  left: leftOffset,
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: Listener(
                    onPointerHover: _onRightPanelMouseMove, // Move hover detection here
                    child: Column(
                      children: [
                        SizeTransition(
                          sizeFactor: _slideAnimation,
                          axisAlignment: -1.0,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: CustomTitleBar(
                              slideAnimation: _slideAnimation,
                              fadeAnimation: _fadeAnimation,
                            ),
                          ),
                        ),
                        Expanded(
                          child: RightPanel(
                            onActionsChanged: _handleActions,
                            onSearchResultChanged: _updateSearchResultCounts,
                            pageLayoutMode: _pageLayoutMode,
                            onFileNameChanged: _handleFileNameChanged,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Left panel (slides in/out from the left)
            AnimatedBuilder(
              animation: _leftPanelAnimation,
              builder: (context, child) {
                final leftOffset = -_leftPanelWidth * (1 - _leftPanelAnimation.value);
                return Positioned(
                  left: leftOffset,
                  top: 0,
                  width: _leftPanelWidth,
                  bottom: 0,
                  child: LeftPanel(
                    key: _leftPanelKey,
                    onSearch: _onSearch ?? (_) {},
                    onNextSearch: _onNextSearch ?? () {},
                    onPrevSearch: _onPrevSearch ?? () {},
                    searchCurrentIndex: _searchCurrentIndex,
                    searchTotalCount: _searchTotalCount,
                    onZoomIn: _zoomIn ?? () {},
                    onZoomOut: _zoomOut ?? () {},
                    onOpenFile: _openFile ?? () {},
                    zoomPercent: _zoomPercent,
                    onJumpToPage: _onJumpToPage ?? (page) {},
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                    onSetSinglePageLayout: _setSinglePageLayout,
                    onSetContinuousLayout: _setContinuousLayout,
                    fileName: _currentFileName,
                    onHidePanel: _hideLeftPanel, // Pass the hide callback
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}