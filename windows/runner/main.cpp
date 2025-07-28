#include <bitsdojo_window_plugin.h>
auto bdw = bitsdojo_window_configure(BDW_CUSTOM_FRAME);

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <dwmapi.h>  
#pragma comment(lib, "dwmapi.lib")

#include "flutter_window.h"
#include "utils.h"

// Store original window procedure
WNDPROC g_originalWndProc = nullptr;

// Custom window procedure to handle white border issues
LRESULT CALLBACK CustomWindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    switch (uMsg) {
        case WM_ERASEBKGND: {
            // Always erase with black background
            HDC hdc = (HDC)wParam;
            RECT rect;
            GetClientRect(hwnd, &rect);
            HBRUSH blackBrush = CreateSolidBrush(RGB(0, 0, 0));
            FillRect(hdc, &rect, blackBrush);
            DeleteObject(blackBrush);
            return 1; // Indicate we handled the erase
        }
        
        case WM_PAINT: {
            // Handle paint to prevent white flashes
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);
            
            // Fill with black first
            HBRUSH blackBrush = CreateSolidBrush(RGB(0, 0, 0));
            FillRect(hdc, &ps.rcPaint, blackBrush);
            DeleteObject(blackBrush);
            
            EndPaint(hwnd, &ps);
            
            // Let the original handler do the rest
            break;
        }
        
        case WM_NCPAINT: {
            // Prevent non-client area painting that might cause white borders
            return 0;
        }
        
        case WM_NCCALCSIZE: {
            // Remove all non-client area
            if (wParam == TRUE) {
                return 0;
            }
            break;
        }
    }
    
    // Call original window procedure for other messages
    return CallWindowProc(g_originalWndProc, hwnd, uMsg, wParam, lParam);
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");
  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();
  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"kdox_library", origin, size)) {
    return EXIT_FAILURE;
  }

  HWND hwnd = ::FindWindow(nullptr, L"kdox_library");
  if (hwnd != nullptr) {
    // Subclass the window to handle messages
    g_originalWndProc = (WNDPROC)SetWindowLongPtr(hwnd, GWLP_WNDPROC, (LONG_PTR)CustomWindowProc);
    
    LONG style = GetWindowLong(hwnd, GWL_STYLE);
    style &= ~WS_CAPTION;
    SetWindowLong(hwnd, GWL_STYLE, style);
    
    // Set black background
    SetClassLongPtr(hwnd, GCLP_HBRBACKGROUND, (LONG_PTR)CreateSolidBrush(RGB(0, 0, 0)));
    
    SetWindowPos(hwnd, nullptr, 0, 0, 0, 0,
                 SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE);
  }

  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}