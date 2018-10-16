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
    

import Foundation

class MaskTool<Reference: Hashable>: ToolMixin<Reference>, Tool {
    
    var lastPoint: NSPoint? = nil
    
    override func didMouseDown(_ point: NSPoint, modifierKeys: NSEvent.ModifierFlags) {
        self.layers.brushPreview = nil
        self.lastPoint = point
        self.layers.drawFullCircleMask(
            point: point,
            width: self.settings.lineWidth,
            masked: !modifierKeys.contains(.shift)
        )
    }
    
    override func didMouseUp(_ point: NSPoint, modifierKeys: NSEvent.ModifierFlags) {
        self.layers.brushPreview = (point: point, width: self.settings.lineWidth)
        self.layers.brushPreview = nil
    }
    
    override func didMoveMouse(_ point: NSPoint, modifierKeys: NSEvent.ModifierFlags) {
        self.layers.brushPreview = (point: point, width: self.settings.lineWidth)
    }
    
    override func didDragMouse(_ point: NSPoint, modifierKeys: NSEvent.ModifierFlags) {
        self.layers.brushPreview = nil
        if let lastPoint = self.lastPoint {
            self.layers.drawLineMask(from: lastPoint,
                                 to: point,
                                 lineWidth: self.settings.lineWidth,
                                 masked: !modifierKeys.contains(.shift))
        }
        self.lastPoint = point
    }
    
    override func didExitMouse() {
        self.layers.brushPreview = nil
    }
    
    override func didPressKey(key: Keycode, modifierKeys: NSEvent.ModifierFlags) -> Bool {
        return self.abortToolIfEscape(key: key)
    }
}
