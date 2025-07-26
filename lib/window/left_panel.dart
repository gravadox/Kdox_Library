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

  // NEW: layout mode toggles
  final VoidCallback onSetSinglePageLayout;
  final VoidCallback onSetContinuousLayout;

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
  });

  @override
  State<LeftPanel> createState() => _LeftPanelState();
}

class _LeftPanelState extends State<LeftPanel> {
  late TextEditingController _pageController;
  late FocusNode _pageFocusNode;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _pageController =
        TextEditingController(text: widget.currentPage.toString());
    _pageFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant LeftPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPage.toString() != _pageController.text &&
        !_pageFocusNode.hasFocus) {
      _pageController.text = widget.currentPage.toString();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageFocusNode.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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
    // Keep focus on search input after submitting
    FocusScope.of(context).requestFocus(_searchFocusNode);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 40, child: MoveWindow()),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Zoom buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildZoomButton(Icons.zoom_out, widget.onZoomOut),
                    const SizedBox(width: 8),
                    _buildZoomButton(Icons.zoom_in, widget.onZoomIn),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.zoomPercent}%',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Layout mode buttons (NEW)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: widget.onSetContinuousLayout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: widget.onSetSinglePageLayout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: _onSearchSubmitted,
                  ),
                ),
                const SizedBox(height: 8),

                // Prev / Next search buttons with match counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNavButton(Icons.arrow_upward, widget.onPrevSearch),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.searchTotalCount == 0 ? 0 : widget.searchCurrentIndex - 1}/${widget.searchTotalCount}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(width: 6),
                    _buildNavButton(Icons.arrow_downward, widget.onNextSearch),
                  ],
                ),
                const SizedBox(height: 20),

                // Page navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 30,
                      child: TextField(
                        controller: _pageController,
                        focusNode: _pageFocusNode,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
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
                  ],
                ),
              ],
            ),

            // Open File button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: widget.onOpenFile,
                  icon: const Icon(Icons.folder_open, color: Colors.white),
                  label: const Text('Open File',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        onPressed: onPressed,
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 40,
      height: 30,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        onPressed: onPressed,
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
