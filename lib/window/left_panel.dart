import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

class LeftPanel extends StatefulWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onOpenFile;
  final int zoomPercent;
  final void Function(String) onSearch;
  final VoidCallback onNextSearch;
  final VoidCallback onPrevSearch;
  final void Function(int) onJumpToPage;
  final int currentPage;
  final int totalPages;
  final int searchCurrentIndex;
  final int searchTotalCount;
  final VoidCallback onSetSinglePageLayout;
  final VoidCallback onSetContinuousLayout;
  final String fileName;
  final VoidCallback? onHidePanel; // Add callback for hiding panel

  const LeftPanel({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onOpenFile,
    required this.zoomPercent,
    required this.onSearch,
    required this.onNextSearch,
    required this.onPrevSearch,
    required this.onJumpToPage,
    required this.currentPage,
    required this.totalPages,
    required this.searchCurrentIndex,
    required this.searchTotalCount,
    required this.onSetSinglePageLayout,
    required this.onSetContinuousLayout,
    required this.fileName,
    this.onHidePanel,
  });

  @override
  State<LeftPanel> createState() => LeftPanelState();
}

// Made public so it can be accessed from WindowFrame
class LeftPanelState extends State<LeftPanel> with TickerProviderStateMixin {
  final double panelItemSize = 42;
  late TextEditingController _pageController;
  late FocusNode _pageFocusNode;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;
  bool _showSearchTools = false;

  @override
  void initState() {
    super.initState();
    _pageController = TextEditingController(text: widget.currentPage.toString());
    _pageFocusNode = FocusNode();
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _searchAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(covariant LeftPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPage.toString() != _pageController.text &&
        !_pageFocusNode.hasFocus) {
      _pageController.text = widget.currentPage.toString();
    }
    if (widget.searchTotalCount > 0 && !_showSearchTools) {
      setState(() {
        _showSearchTools = true;
      });
      _searchAnimationController.forward();
    } else if (widget.searchTotalCount == 0 && _showSearchTools) {
      _searchAnimationController.reverse().then((_) {
        setState(() {
          _showSearchTools = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageFocusNode.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  // Public method to focus the search field
  void focusSearchField() {
    // Use multiple frame callbacks to ensure everything is settled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _searchFocusNode.canRequestFocus) {
            _searchFocusNode.requestFocus();
            // Select all text in the search field for easy replacement
            _searchController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _searchController.text.length,
            );
          }
        });
      }
    });
  }

  void _onPageSubmitted(String value) {
    final page = int.tryParse(value);
    if (page != null &&
        page >= 1 &&
        page <= widget.totalPages &&
        page != widget.currentPage) {
      widget.onJumpToPage(page);
      _pageFocusNode.unfocus();
    } else {
      _pageController.text = widget.currentPage.toString();
      _pageFocusNode.unfocus();
    }
  }

  void _onSearchSubmitted(String value) {
    widget.onSearch(value);
    FocusScope.of(context).requestFocus(_searchFocusNode);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            // TOP SECTION WITH FILE NAME AND HIDE BUTTON
            SizedBox(
              height: 40, 
              child: MoveWindow(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: panelItemSize,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.fileName,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      // HIDE PANEL BUTTON
                      if (widget.onHidePanel != null)
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: widget.onHidePanel,
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                child: const Icon(
                                  Icons.chevron_left,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // SEARCH INPUT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Container(
                height: panelItemSize,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  color: Color.fromARGB(25, 255, 255, 255),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'search',
                    hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: _onSearchSubmitted,
                ),
              ),
            ),
            // SEARCH NAV BUTTONS
            AnimatedBuilder(
              animation: _searchAnimation,
              builder: (context, child) {
                return SizeTransition(
                  sizeFactor: _searchAnimation,
                  child: _showSearchTools
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Container(
                            height: panelItemSize,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    '${widget.searchCurrentIndex}/${widget.searchTotalCount}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ),
                                const Spacer(),
                                _buildTransparentIcon(Icons.keyboard_arrow_up, widget.onPrevSearch),
                                _buildTransparentIcon(Icons.keyboard_arrow_down, widget.onNextSearch),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
            const SizedBox(height: 12),
            // ZOOM CONTROLS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: panelItemSize,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${widget.zoomPercent}%',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: panelItemSize,
                          height: panelItemSize,
                          child: _buildIconButton(Icons.remove, widget.onZoomOut),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: panelItemSize,
                          height: panelItemSize,
                          child: _buildIconButton(Icons.add, widget.onZoomIn),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                      children: [
                        Expanded(
                          child: _buildIconButton(Icons.view_agenda_outlined, widget.onSetContinuousLayout),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildIconButton(Icons.view_module_outlined, widget.onSetSinglePageLayout),
                        ),
                      ],
                    ),
            ),
            const Spacer(),
            // PAGE INPUT AND COUNTER
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 28,
                      child: TextField(
                        controller: _pageController,
                        focusNode: _pageFocusNode,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.white, fontSize: 14.0),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                        ),
                        onSubmitted: _onPageSubmitted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '/ ${widget.totalPages}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 12),
                  ],
                ),
            // OPEN FILE BUTTON
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity,
                height: panelItemSize,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: widget.onOpenFile,
                  icon: const Icon(Icons.folder_open, color: Colors.white70, size: 16),
                  label: const Text(
                    'open a file',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: panelItemSize,
      height: panelItemSize,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(color: Colors.white.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Icon(icon, color: Colors.white70, size: 16),
      ),
    );
  }

  Widget _buildTransparentIcon(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, size: 18, color: Colors.white70),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      splashRadius: 20,
      onPressed: onPressed,
    );
  }
}