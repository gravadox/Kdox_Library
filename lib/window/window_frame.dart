import 'package:flutter/material.dart';
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
      body: Listener(
        onPointerHover: _onMouseMove,
        child: Container(
          color: const Color.fromARGB(179, 0, 0, 0),
          child: Row(
            children: [
              LeftPanel(
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
              ),

              Expanded(
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
