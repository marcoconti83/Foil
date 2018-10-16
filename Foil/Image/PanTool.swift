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

final class PanTool<Reference: Hashable>: ToolMixin<Reference>, Tool {
    
    private var hasDrag: Bool {
        return self.lastMousePosition != nil
    }
    private var lastMousePosition: NSPoint?
    
    override func didDragMouse(_ point: NSPoint, modifierKeys: NSEvent.ModifierFlags) {
        defer { self.lastMousePosition = point }
        guard let last = self.lastMousePosition else {
            return
        }
        let diff = last - point
        self.delegate?.pan(x: diff.x, y: diff.y)
    }
    
    override func didMouseUp(_ point: NSPoint, modifierKeys: NSEvent.ModifierFlags) {
        self.delegate?.selectTool(.selection)
        if !hasDrag {
            self.layers.selectedBitmaps = []
        }
    }
    
}
