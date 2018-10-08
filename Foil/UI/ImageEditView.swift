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

import Foundation
import Cocoa
import Cartography

public class ImageEditView: NSView {

    private var editor: ImageEditor!
    private var mouseTrackingArea: NSTrackingArea? = nil
    
    weak var scrollDelegate: ScrollDelegate?
    
    public override init(frame frameRect: NSRect) {
        self.editor = ImageEditor(emptyImageOfSize: NSSize(width: 500, height: 500))
        super.init(frame: frameRect)
        constrain(self) { s in
            s.width == self.editor.size.width
            s.height == self.editor.size.height
        }
        self.editor.toolType = .selection
        self.toolSettings.lineWidth = 4
        self.editor.delegate = self
    }
    
    public required init?(coder decoder: NSCoder) {
        fatalError()
    }
    
}

// MARK: - UI events
extension ImageEditView {
    
    public override var acceptsFirstResponder: Bool {
        return true
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        self.editor.layers.imageBeingEdited.draw(in: self.frame)
    }
    
    public override func mouseDown(with event: NSEvent) {
        self.editor.tool.didMouseDown(self.eventLocation(event), modifierKeys: event.modifierFlags)
    }
    
    public override func mouseUp(with event: NSEvent) {
        self.editor.tool.didMouseUp(self.eventLocation(event), modifierKeys: event.modifierFlags)
    }
    
    public override func mouseDragged(with event: NSEvent) {
        self.editor.tool.didDragMouse(self.eventLocation(event), modifierKeys: event.modifierFlags)
    }
    
    public override func mouseMoved(with event: NSEvent) {
        self.editor.tool.didMoveMouse(self.eventLocation(event), modifierKeys: event.modifierFlags)
    }
    
    public override func mouseExited(with event: NSEvent) {
        self.editor.tool.didExitMouse()
    }
    
    private func eventLocation(_ event: NSEvent) -> NSPoint {
        return self.convert(event.locationInWindow, from: nil)
    }
    
    public override func updateTrackingAreas() {
        if let area = self.mouseTrackingArea {
            self.removeTrackingArea(area)
        }
        let options: NSTrackingArea.Options =
            [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow]
        self.mouseTrackingArea = NSTrackingArea(rect: self.bounds, options: options,
                                      owner: self, userInfo: nil)
        self.addTrackingArea(self.mouseTrackingArea!)
    }
    
    public override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard let keycode = Keycode(rawValue: event.keyCode) else { return false }
        return self.editor.tool.didPressKey(key: keycode, modifierKeys: event.modifierFlags)
    }
    
    public override func resetCursorRects() {
        let cursor = self.editor.toolType.cursor
        self.discardCursorRects()
        self.addCursorRect(self.frame, cursor: cursor)
    }
    
}

// MARK: - Editor events
extension ImageEditView: ImageEditorDelegate {
    
    public func didChangeTool(_ tool: ToolType) {
        tool.cursor.set()
        self.resetCursorRects()
    }
    
    public func didRedrawImage() {
        self.needsDisplay = true
    }
    
    public func didScroll(x: CGFloat, y: CGFloat) {
        self.scrollDelegate?.scroll(x: x, y: y)
    }
    
    public var tool: ToolType {
        get {
            return self.editor.toolType
        }
        set {
            self.editor.toolType = newValue
        }
    }
    
    public var toolSettings: ToolSettings {
        get {
            return self.editor.toolSettings
        }
        set {
            self.editor.toolSettings = newValue
        }
    }
}

extension ToolType {
    
    var cursor: NSCursor {
        switch self {
        case .selection:
            return NSCursor.arrow
        case .line:
            return NSCursor.crosshair
        case .bitmap:
            return NSCursor.crosshair
        case .pan:
            return NSCursor.closedHand
        case .brush:
            return NSCursor.arrow
        case .eraser:
            return NSCursor.arrow
        }
    }
}

protocol ScrollDelegate: AnyObject {
    func scroll(x: CGFloat, y: CGFloat)
}
