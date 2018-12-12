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

final class SelectionTool<Reference: Hashable>: ToolMixin<Reference>, Tool {
    private var currentOperation: ToolMixin<Reference>? = nil
    
    override func didMouseDown(_ point: NSPoint, modifierKeys: NSEvent.ModifierFlags) {
        
        // if there's no bitmap, switch to pan
        guard let bitmap = self.bitmapAtPoint(point, considerHandles: true) else {
            if !modifierKeys.contains(NSEvent.ModifierFlags.shift) {
                self.delegate?.selectTool(.pan)
            }
            return
        }
        
        // did I pick an handle?
        if let handle = bitmap.handleForPoint(point) {
            self.currentOperation = ScaleBitmapOperation(
                layers: self.layers,
                settings: self.settings,
                delegate: self.delegate!,
                corner: handle,
                bitmap: bitmap)
        } else {
            self.currentOperation = MoveOrSelectBitmapOperation(
                layers: self.layers,
                settings: self.settings,
                delegate: self.delegate!,
                bitmap: bitmap)
        }
        self.currentOperation?.didMouseDown(point, modifierKeys: modifierKeys)
    }
    
    override func didDragMouse(_ point: NSPoint, modifierKeys: NSEvent.ModifierFlags) {
        self.currentOperation?.didDragMouse(point, modifierKeys: modifierKeys)
    }
    
    override func didMouseUp(_ point: NSPoint, modifierKeys: NSEvent.ModifierFlags) {
        self.currentOperation?.didMouseUp(point, modifierKeys: modifierKeys)
        if self.currentOperation == nil && !modifierKeys.contains(NSEvent.ModifierFlags.shift)
        {
            self.layers.selectedBitmaps = Set()
        }
        self.currentOperation = nil
    }
    
    
    override func didPressKey(key: Keycode, modifierKeys: NSEvent.ModifierFlags) -> Bool {
        switch key {
        case .delete, .forwardDelete:
            self.layers.bitmaps = self.layers.bitmaps.filter { !self.layers.selectedBitmaps.contains($0) }
            self.layers.selectedBitmaps = Set()
        case .a where modifierKeys.contains(.command):
            self.layers.selectedBitmaps = self.layers.bitmaps
        case .escape:
            break
        default:
            return false
        }
        return true
    }
}

extension ToolMixin {
    
    fileprivate func bitmapAtPoint(_ point: NSPoint, considerHandles: Bool) -> Bitmap<Reference>? {
        return self.layers.bitmaps.first(where: {
            if $0.drawingRect.contains(point) {
                return true
            }
            
            if $0.drawingRect.expand(by: FoilValues.handleSize / 2.0).contains(point) {
                let handle = $0.corners
                    .map { $0.point.asCenterForSquare(size: FoilValues.handleSize)}
                    .first { $0.contains(point) }
                return handle != nil
            }
            return false
        })
    }
}

// MARK: - Scale
class ScaleBitmapOperation<Reference: Hashable>: ToolMixin<Reference> {
    
    private var corner: Corner
    private var lastDragPoint: NSPoint!
    private var bitmap: Bitmap<Reference>
    private var didDragOnce: Bool = false
    
    init(
        layers: ImageLayers<Reference>,
        settings: ToolSettings,
        delegate: ToolDelegate,
        corner: Corner,
        bitmap: Bitmap<Reference>)
    {
        self.corner = corner
        self.bitmap = bitmap
        super.init(layers: layers, settings: settings, delegate: delegate)
    }
    
    override func didMouseDown(_ point: NSPoint, modifierKeys: NSEvent.ModifierFlags) {
        self.lastDragPoint = point
    }
    
    override func didDragMouse(_ point: NSPoint, modifierKeys: NSEvent.ModifierFlags) {
        
        defer {
            self.lastDragPoint = point
            self.didDragOnce = true
        }
        
        let newCorner = Corner(point: point, direction: self.corner.direction)
        let modifiedRect = self.bitmap.imageOnlyRect.scaleToCorner(newCorner)
        let newScale = min(modifiedRect.size.width / self.bitmap.image.size.width,
                           modifiedRect.size.height / self.bitmap.image.size.height)
        let newRect = NSRect(origin: modifiedRect.origin, size: self.bitmap.image.size * newScale)
            .move(corner: self.corner.direction.opposite,
                  to: self.bitmap.drawingRect.corner(self.corner.direction.opposite).point)
        
        let newBitmap = Bitmap(image: self.bitmap.image,
                               centerPosition: newRect.center,
                               scale: newScale,
                               label: self.bitmap.label,
                               reference: self.bitmap.reference)
        self.layers.replace(originalBitmap: self.bitmap, newBitmap: newBitmap)
        self.bitmap = newBitmap
        self.corner = newCorner
    }
}

// MARK: - Move
class MoveOrSelectBitmapOperation<Reference: Hashable>: ToolMixin<Reference> {
    
    private var lastDragPoint: NSPoint? = nil
    private var didDragOnce: Bool = false
    private let bitmap: Bitmap<Reference>
    
    init(
        layers: ImageLayers<Reference>,
        settings: ToolSettings,
        delegate: ToolDelegate,
        bitmap: Bitmap<Reference>)
    {
        self.bitmap = bitmap
        super.init(layers: layers, settings: settings, delegate: delegate)
    }
    
    override func didMouseDown(_ point: NSPoint, modifierKeys: NSEvent.ModifierFlags) {
        self.didDragOnce = false
        self.lastDragPoint = point
        if modifierKeys.contains(NSEvent.ModifierFlags.shift) {
            // Shift was pressed: this is a multi-selection operation
            // either add or remove from the selected set
            if self.layers.selectedBitmaps.contains(self.bitmap) { // unselect if selected
                self.layers.selectedBitmaps.remove(self.bitmap)
            } else { // add
                self.layers.selectedBitmaps.insert(self.bitmap)
            }
        } else if !self.layers.selectedBitmaps.contains(self.bitmap) {
            // if it was not already selected, replace entire
            // selection with it. But if it was, we might need to drag
            // all bitmaps
            self.layers.selectedBitmaps = Set([self.bitmap])
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
    
}

extension Bitmap {
    
    func handleForPoint(_ point: NSPoint) -> Corner? {
        return self.corners.first { c in
            c.point.asCenterForSquare(size: FoilValues.handleSize).contains(point)
        }
    }
}
