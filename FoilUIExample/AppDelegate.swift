//
//
// Copyright (c) 2018 Marco Conti
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
    

import Cocoa
import Foil

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    static var defaultSettings: ImageEditorSettings<Int> {
        var settings = ImageEditorSettings<Int>()
        settings.possibleBitmaps = [
            NSImage(name: "e.png", fromClassBundle: AppDelegate.self),
            NSImage(name: "o.png", fromClassBundle: AppDelegate.self),
            NSImage(name: "u.png", fromClassBundle: AppDelegate.self)
            ].compactMap { $0 }
        return settings
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        var settings = AppDelegate.defaultSettings
        settings.backgroundImage = NSImage(name: "sky.jpg", fromClassBundle: AppDelegate.self)
        window.contentView = EditorView(settings: settings)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    @objc func saveDocumentAs(_ sender: Any) {
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["jpg"]
        panel.canCreateDirectories = false
        panel.beginSheetModal(for: NSApp.keyWindow!) { [weak self] response in
            guard response == .OK, let url = panel.url,
                let controller = self?.window.contentView as? EditorView<Int> else {
                return
            }
            do {
                try controller.image.jpgWrite(to: url)
            } catch {
                let alert = NSAlert()
                alert.messageText = "Can't save to \(url)"
                alert.runModal()
            }
        }
    }

    @objc func newDocument(_ sender: Any) {
        let settings = AppDelegate.defaultSettings
        window.contentView = EditorView(settings: settings)
    }

    @objc func openDocument(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedFileTypes = ["jpg", "jpeg", "png"]
        panel.beginSheetModal(for: NSApp.keyWindow!) { [weak self] response in
            guard response == .OK, let image = panel.url.flatMap({ NSImage(contentsOf: $0)}) else {
                return
            }
            var settings = AppDelegate.defaultSettings
            settings.backgroundImage = image
            self?.window.contentView = EditorView(settings: settings)
        }
    }

}

