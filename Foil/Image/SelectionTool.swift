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
    private var currentOperation: SelectionToolOperation? = nil
    
    override func didMouseDown(_ point: NSPoint, modifierKeys: NSEvent.ModifierFlags) {
        
        
        // if there's no bitmap, switch to pan
        guard let bitmap = self.bitmapAtPoint(point) else {
            if !modifierKeys.contains(NSEvent.ModifierFlags.shift) {
                self.delegate?.selectTool(.pan)
            }
            return
        }
        
        self.currentOperation = MoveOrSelectBitmapOperation(
            layers: self.layers,
            settings: self.settings,
            delegate: self.delegate!
        )
        self.currentOperation?.didMouseDownOnBitmap(point, modifierKeys: modifierKeys, bitmap: bitmap)
    }
    
    override func didDragMouse(_ point: NSPoint, modifierKeys: NSEvent.ModifierFlags) {
        self.currentOperation?.didDragMouse(point, modifierKeys: modifierKeys)
    }
    
    override func didMouseUp(_ point: NSPoint, modifierKeys: NSEvent.ModifierFlags) {
        self.currentOperation?.didMouseUp(point, modifierKeys: modifierKeys)
    }
    
    
    override func didPressKey(key: Keycode, modifierKeys: NSEvent.ModifierFlags) -> Bool {
        switch key {
        case .delete, .forwardDelete:
            self.layers.bitmaps = self.layers.bitmaps.filter { !self.layers.selectedBitmaps.contains($0) }
            self.layers.selectedBitmaps = Set()
        case .a where modifierKeys.contains(.command):
            self.layers.selectedBitmaps = self.layers.bitmaps
        default:
            return false
        }
        return true
    }
}

extension ToolMixin {
    
    fileprivate func bitmapAtPoint(_ point: NSPoint) -> Bitmap? {
        return self.layers.bitmaps.first(where: {
            $0.drawingRect.contains(point)
        })
    }
}


class SelectionToolOperation: ToolMixin {
    
    func didMouseDownOnBitmap(_ point: NSPoint, modifierKeys: NSEvent.ModifierFlags, bitmap: Bitmap) {}
}

// MARK: - Scale
class ScaleBitmapOperation: SelectionToolOperation {
    
    
}

// MARK: - Move
class MoveOrSelectBitmapOperation: SelectionToolOperation {
    
    private var lastDragPoint: NSPoint? = nil
    private var didDragOnce: Bool = false
    
    override func didMouseDownOnBitmap(_ point: NSPoint, modifierKeys: NSEvent.ModifierFlags, bitmap: Bitmap) {
        self.lastDragPoint = nil
        self.didDragOnce = false
        
        self.lastDragPoint = point
        if modifierKeys.contains(NSEvent.ModifierFlags.shift) {
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
    
    override func didDragMouse(_ point: NSPoint, modifierKeys: NSEvent.ModifierFlags) {
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
    
    override func didMouseUp(_ point: NSPoint, modifierKeys: NSEvent.ModifierFlags) {
        
        if self.bitmapAtPoint(point) == nil // did not click bitmap
            && !self.didDragOnce // there was no drag in between
            && !modifierKeys.contains(NSEvent.ModifierFlags.shift)
        {
            self.layers.selectedBitmaps = Set()
        }
        self.lastDragPoint = nil
        self.didDragOnce = false
    }
    
}
