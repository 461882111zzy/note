import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
      if let window = NSApplication.shared.windows.first {
          window.backgroundColor = NSColor.white
          window.titleVisibility = .hidden
      }
  }
    
  override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    if(flag){
        return true
    }else{
        self.mainFlutterWindow?.makeKeyAndOrderFront(self)
        return true
     }
   }
}
