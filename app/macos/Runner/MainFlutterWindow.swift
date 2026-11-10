import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  /// Smallest size at which the workbench (two strips, center, overlay
  /// panels) lays out without clipping.
  private static let minimumContentSize = NSSize(width: 1024, height: 720)
  /// Opening size, matching the reference design width.
  private static let initialContentSize = NSSize(width: 1440, height: 960)

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    self.title = "Ermias"
    self.contentMinSize = Self.minimumContentSize
    self.setContentSize(Self.initialContentSize)
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
