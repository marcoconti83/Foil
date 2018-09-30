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

final class SelectionTool: ToolMixin, Tool {
    
    private func bitmapAtPoint(_ point: NSPoint) -> Bitmap? {
        return self.layers.bitmaps.first(where: {
            $0.drawingRect.contains(point)
        })
    }
    
    override func didMouseDown(_ point: NSPoint, shiftKeyPressed: Bool) {
        guard self.bitmapAtPoint(point) == nil else {
            return
        }
        self.delegate?.selectTool(.pan)
    }
    
    override func didMouseUp(_ point: NSPoint, shiftKeyPressed: Bool) {
        guard let selectedBitmap = self.bitmapAtPoint(point) else {
            if !shiftKeyPressed {
                self.layers.selectedBitmaps = Set()
            }
            return
        }
        
        if shiftKeyPressed {
            if self.layers.selectedBitmaps.contains(selectedBitmap) {
                self.layers.selectedBitmaps.remove(selectedBitmap)
            } else {
                self.layers.selectedBitmaps.insert(selectedBitmap)
            }
        } else {
            self.layers.selectedBitmaps = Set([selectedBitmap])
        }
    }
    
    
    override func didPressKey(key: Keycode) {
        if key == .delete || key == .forwardDelete {
            self.layers.bitmaps = self.layers.bitmaps.filter { !self.layers.selectedBitmaps.contains($0) }
            self.layers.selectedBitmaps = Set()
        }
    }
}
