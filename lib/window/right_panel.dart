import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

class RightPanel extends StatefulWidget {
  final void Function(
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
  ) onActionsChanged;

  final void Function(int currentIndex, int totalCount)? onSearchResultChanged;
  final PdfPageLayoutMode pageLayoutMode;

  const RightPanel({
    super.key,
    required this.onActionsChanged,
    this.onSearchResultChanged,
    required this.pageLayoutMode,
  });

  @override
  State<RightPanel> createState() => _RightPanelState();
}

class _RightPanelState extends State<RightPanel> {
  late PdfViewerController _pdfController;
  PdfTextSearchResult? _searchResult;
  String? _filePath;
  int _currentPage = 1;
  int _totalPages = 1;
  double _viewerZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
  }

  @override
  void dispose() {
    _searchResult?.removeListener(_onSearchResultChanged);
    super.dispose();
  }

  void _onSearchResultChanged() {
    if (_searchResult == null) return;
    final currentIndex = _searchResult!.currentInstanceIndex + 1;
    final totalCount = _searchResult!.totalInstanceCount;
    widget.onSearchResultChanged?.call(currentIndex, totalCount);
    setState(() {});
  }

  void _notifyActions() {
    widget.onActionsChanged(
      _zoomIn,
      _zoomOut,
      _openFile,
      (_viewerZoom * 100).round(),
      _performSearch,
      () => _searchResult?.nextInstance(),
      () => _searchResult?.previousInstance(),
      _jumpToPage,
      _currentPage,
      _totalPages,
    );
  }

  Future<void> _performSearch(String text) async {
    final result = await _pdfController.searchText(text);
    _searchResult?.removeListener(_onSearchResultChanged);
    _searchResult = result;
    _searchResult?.addListener(_onSearchResultChanged);
    setState(() {});
  }

  void _jumpToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      _pdfController.jumpToPage(page);
    }
  }

  Future<void> _openFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null && result.files.single.path!.isNotEmpty) {
      setState(() {
        _filePath = result.files.single.path!;
        _pdfController = PdfViewerController();
        _searchResult?.removeListener(_onSearchResultChanged);
        _searchResult = null;
        _viewerZoom = 1.0;
        _currentPage = 1;
        _totalPages = 1;
      });
    }
  }

  void _zoomIn() {
    setState(() {
      _viewerZoom = (_viewerZoom + 0.2).clamp(1.0, 5.0);
      _pdfController.zoomLevel = _viewerZoom;
    });
  }

  void _zoomOut() {
    setState(() {
      _viewerZoom = (_viewerZoom - 0.2).clamp(1.0, 5.0);
      _pdfController.zoomLevel = _viewerZoom;
    });
  }

  @override
  Widget build(BuildContext context) {
    _notifyActions();
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          final isCtrl = RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.controlLeft) ||
              RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.controlRight);
          if (isCtrl) {
            if (event.logicalKey == LogicalKeyboardKey.equal || event.logicalKey == LogicalKeyboardKey.numpadAdd) {
              _zoomIn();
            } else if (event.logicalKey == LogicalKeyboardKey.minus || event.logicalKey == LogicalKeyboardKey.numpadSubtract) {
              _zoomOut();
            }
          }
        }
      },
      child: Listener(
        onPointerSignal: (event) {
          final ctrlPressed = RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.controlLeft) ||
              RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.controlRight);
          if (ctrlPressed && event is PointerScrollEvent) {
            if (event.scrollDelta.dy < 0) {
              _zoomIn();
            } else {
              _zoomOut();
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: const Color.fromARGB(51, 0, 0, 0),
              child: _filePath == null || _filePath!.isEmpty
                  ? Center(
                      child: InkWell(
                        onTap: _openFile,
                        child: const Text(
                          'Click to open a PDF file',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    )
                  : SfPdfViewer.file(
                      File(_filePath!),
                      key: ValueKey(_filePath),
                      controller: _pdfController,
                      pageLayoutMode: widget.pageLayoutMode,
                      onDocumentLoaded: (details) {
                        setState(() {
                          _totalPages = details.document.pages.count;
                          _pdfController.zoomLevel = _viewerZoom;
                        });
                      },
                      onPageChanged: (details) {
                        setState(() {
                          _currentPage = details.newPageNumber;
                        });
                      },
                      enableDoubleTapZooming: false,
                      enableTextSelection: true,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
