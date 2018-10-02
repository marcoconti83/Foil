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

    private var lastDragPoint: NSPoint? = nil
    private var didDragOnce: Bool = false
    
    private func bitmapAtPoint(_ point: NSPoint) -> Bitmap? {
        return self.layers.bitmaps.first(where: {
            $0.drawingRect.contains(point)
        })
    }
    
    override func didMouseDown(_ point: NSPoint, shiftKeyPressed: Bool) {
        self.lastDragPoint = nil
        self.didDragOnce = false
        
        // if there's no bitmap, switch to pan
        guard let bitmap = self.bitmapAtPoint(point) else {
            if !shiftKeyPressed {
                self.delegate?.selectTool(.pan)
            }
            return
        }
        
        self.lastDragPoint = point
        if shiftKeyPressed {
            // Shift was pressed: this is a multi-selection operation
            // either add or remove from the selected set
            if self.layers.selectedBitmaps.contains(bitmap) { // unselect if selected
                self.layers.selectedBitmaps.remove(bitmap)
            } else { // add
                self.layers.selectedBitmaps.insert(bitmap)
            }
        } else if !self.layers.selectedBitmaps.contains(bitmap) {
            // if it was not already selected, replace entire
            // selection with it. But if it was, we might need to drag
            // all bitmaps
            self.layers.selectedBitmaps = Set([bitmap])
        }
    }
    
    override func didDragMouse(_ point: NSPoint) {
        defer {
            self.lastDragPoint = point
            self.didDragOnce = true
        }
        
        // this should happen only if a bitmap was selected with mouse down,
        guard let lastPoint = lastDragPoint, !self.layers.selectedBitmaps.isEmpty else {
            return
        }
        let diff = point - lastPoint
        self.layers.batchOperations {
            let newBitmaps = self.layers.selectedBitmaps.map {
                $0.moving(by: diff)
            }
            let toRemove = self.layers.selectedBitmaps
            toRemove.forEach {
                self.layers.bitmaps.remove($0)
            }
            self.layers.bitmaps.formUnion(newBitmaps)
            self.layers.selectedBitmaps = Set(newBitmaps)
        }
    }
    
    override func didMouseUp(_ point: NSPoint, shiftKeyPressed: Bool) {
        
        if self.bitmapAtPoint(point) == nil // did not click bitmap
            && !self.didDragOnce // there was no drag in between
            && !shiftKeyPressed
        {
            self.layers.selectedBitmaps = Set()
        }
        self.lastDragPoint = nil
        self.didDragOnce = false
    }
    
    
    override func didPressKey(key: Keycode) {
        if key == .delete || key == .forwardDelete {
            self.layers.bitmaps = self.layers.bitmaps.filter { !self.layers.selectedBitmaps.contains($0) }
            self.layers.selectedBitmaps = Set()
        }
    }
}
