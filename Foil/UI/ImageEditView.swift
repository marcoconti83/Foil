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
    
    var editor: ImageEditor!
    
    public override init(frame frameRect: NSRect) {
        self.editor = ImageEditor(emptyImageOfSize: NSSize(width: 500, height: 500))
        super.init(frame: frameRect)
        constrain(self) { s in
            s.width == self.editor.size.width
            s.height == self.editor.size.height
        }
        self.editor.setTool(.line)
        self.editor.layers.redrawDelegate = { [weak self] in
            guard let self = self else { return }
            self.needsDisplay = true
        }
    }
    
    public required init?(coder decoder: NSCoder) {
        fatalError()
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        self.editor.layers.renderResult.draw(in: self.frame)
    }
    
    public override func mouseDown(with event: NSEvent) {
        self.editor.tool.didMouseDown(self.eventLocation(event), shiftKeyPressed: event.modifierFlags.contains(.shift))
    }
    
    public override func mouseUp(with event: NSEvent) {
        self.editor.tool.didMouseUp(self.eventLocation(event), shiftKeyPressed: event.modifierFlags.contains(.shift))
    }
    
    public override func mouseDragged(with event: NSEvent) {
        self.editor.tool.didDragMouse(self.eventLocation(event))
    }
    
    public override func mouseMoved(with event: NSEvent) {
        self.editor.tool.didMoveMouse(self.eventLocation(event))
    }
    
    private func eventLocation(_ event: NSEvent) -> NSPoint {
        return self.convert(event.locationInWindow, from: nil)
    }
    
    var mouseTrackingArea: NSTrackingArea? = nil
    
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
}

