## <img alt="Icon" width="21" style="vertical-align: middle;" src="https://github.com/user-attachments/assets/be761579-a989-4750-8f17-be9d6bb4eb2c" /> Kdox Minimal PDF Viewer

Fast, lightweight, and distraction-free PDF viewer built for simplicity and performance.  
Designed to open PDFs quickly without consuming system resources.  
Currently available for **Windows**, with support for other platforms soon to come.

---

## Features

- **Lightweight and fast** launches quickly uses little resources
- **Minimal UI**, focuses on the document, not the chrome  
- **Acrylic & transparent UI**, modern, glassy look on Windows 10+  
- **Search** with result navigation  
- **Jump to page** via editable counter  
- **Zoom in/out** with buttons, keyboard `ctrl + ` / `ctrl -`  
- Quick **file open** pinned side bar button
- **Custom title bar & layout**  
  - Title bar appears only when hovering at the top  
  - Sidebar can be toggled with `Ctrl + S` or using the button  
- Built with **Flutter + Syncfusion PDF Viewer**

---

## Showcase
<img src="https://raw.githubusercontent.com/gravadox/Kdox_Library/main/screenshots/1.png"/>
<img src="https://raw.githubusercontent.com/gravadox/Kdox_Library/main/screenshots/2.png"/>
<img src="https://raw.githubusercontent.com/gravadox/Kdox_Library/main/screenshots/3.png"/>

---

## Installation

### Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Dart SDK
- Windows 10+ (for acrylic blur support)

### Run in development

```bash
flutter run -d windows
```
### Build for production or use
```bash
flutter build  windows
```

## Planned Features & todos

- Cross-platform support (Linux, macOS)
- settings menu to control features
- Auto-update mechanism
- optimizations for larger pdf files and lag prevention + handling large images & complex layout
- multi-tabs and & split-view
- Command line support `kdox path/to/file.pdf`
- More zoom controls (fit-to-width, fit-to-page) & touchpad zoom support
- Dark mode toggle
- Bookmark / favorite pages
- Recent files list
- Remember last opened file & page
- Touchscreen and stylus support
- PDF annotations / highlights