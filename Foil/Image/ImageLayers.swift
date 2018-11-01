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

/// Layers that compose the image: background, foreground, vector layer and so on
public class ImageLayers<Reference: Hashable> {
    
    public let imageBeingEdited: NSImage
    
    /// How thick is the selection line width
    let selectionLineWidth: CGFloat
    
    private var shouldRedraw: Bool = true
    
    var redrawDelegate: (()->())? = nil
    
    /// An image to be used as background
    public var backgroundImage: NSImage {
        didSet {
            self.redrawIfNeeded(rects: [self.rasterLayer.size.toRect])
        }
    }
    
    /// Background color drawn below the rest
    public var backgroundColor: NSColor = NSColor.white {
        didSet {
            self.redrawIfNeeded(rects: [self.rasterLayer.size.toRect])
        }
    }
    
    /// Bitmaps objects
    public var bitmaps: Set<Bitmap<Reference>> = Set() {
        didSet {
            let newSelection = self.selectedBitmaps.intersection(bitmaps)
            self.batchOperations {
                self.selectedBitmaps = newSelection
            }
        }
    }
    
    /// Bitmaps that are currently selected
    internal(set) public var selectedBitmaps = Set<Bitmap<Reference>>() {
        didSet {
            self.redrawIfNeeded(rect: self.rasterLayer.size.toRect)
            if self.selectedBitmaps != oldValue {
                self.notifySelectionChange()
            }
        }
    }
    
    /// Line being drawn
    /// This is a temporary line until it gets confirmed
    var lineBeingDrawn: Line? = nil {
        didSet {
            // TODO: old line, new line
            self.redrawIfNeeded()
        }
    }
    
    var brushPreview: (point: NSPoint, width: CGFloat)? = nil {
        didSet {
            // TODO: old selected, new selected
            self.redrawIfNeeded()
        }
    }
    
    /// A layer holding raster data, to be overimposed on background image and color
    let rasterLayer: NSImage
    
    /// A mask layer
    let maskLayer: NSImage
    
    public convenience init(emptyImageOfSize size: NSSize) {
        let backgroundImage = NSImage(emptyClearImageWithSize: size)
        self.init(backgroundImage: backgroundImage)
    }
    
    init(backgroundImage: NSImage,
         backgroundColor: NSColor,
         rasterLayer: NSImage,
         maskLayer: NSImage,
         bitmaps: Set<Bitmap<Reference>>)
    {
        self.imageBeingEdited = NSImage(emptyClearImageWithSize: backgroundImage.size)
        self.rasterLayer = rasterLayer
        self.maskLayer = maskLayer
        self.backgroundColor = backgroundColor
        self.backgroundImage = backgroundImage
        self.selectionLineWidth = max(1, backgroundImage.size.max / 200)
        self.bitmaps = bitmaps
        self.redraw(rect: [self.rasterLayer.size.toRect])
    }
    
    public init(backgroundImage: NSImage) {
        self.imageBeingEdited = NSImage(emptyClearImageWithSize: backgroundImage.size)
        self.rasterLayer = NSImage(emptyClearImageWithSize: backgroundImage.size)
        self.backgroundImage = backgroundImage
        self.maskLayer = NSImage(emptyClearImageWithSize: backgroundImage.size)
        self.selectionLineWidth = max(1, backgroundImage.size.max / 200)
        self.redraw(rect: [self.rasterLayer.size.toRect])
    }
    
}

// MARK: - Redraw
extension ImageLayers {
    
    private func redraw(rects: [NSRect]) {
        rects.forEach { rect in
            self.render(target: self.imageBeingEdited, rect: rect, drawForEditing: true)
        }
        self.redrawDelegate?()
    }
    
    private func render(target: NSImage, rect: NSRect, drawForEditing: Bool) {
        target.lockingFocus {
            self.backgroundColor.drawSwatch(in: rect)
            self.backgroundImage.draw(in: rect, from: rect, operation: .sourceOver, fraction: 1)
            self.rasterLayer.draw(in: rect, from: rect, operation: .sourceOver, fraction: 1)
            if drawForEditing {
                self.drawTemporaryLine() // TODO
                self.drawTemporaryBrush() // TODO
            }
            self.bitmaps.forEach { bmp in
                bmp.draw() // TODO only if in rect
                if drawForEditing && self.selectedBitmaps.contains(bmp) {
                    bmp.drawSelectionOverlay(lineWidth: self.selectionLineWidth)
                }
            }
            self.maskLayer.draw(
                in: rect,
                from: self.maskLayer.size.toRect, // TODO only matching rect
                operation: NSCompositingOperation.sourceAtop,
                fraction: drawForEditing ? 0.5 : 1.0
            )
        }
    }
    
    var renderedImage: NSImage {
        let image = NSImage(size: self.imageBeingEdited.size)
        self.render(target: image, rect: self.imageBeingEdited.size.toRect, drawForEditing: false)
        return image
    }
    
    private func drawTemporaryLine() {
        guard let temporaryLine = self.lineBeingDrawn else {
            return
        }
        restoringGraphicState {
            temporaryLine.draw()
        }
    }
    
    private func drawTemporaryBrush() {
        guard let brush = self.brushPreview else {
            return
        }
        restoringGraphicState {
            NSColor.white.setStroke()
            let source = brush.point - NSPoint(x: brush.width/2, y: brush.width/2)
            let path = NSBezierPath(ovalIn: NSRect(x: source.x, y: source.y,
                                                   width: brush.width, height: brush.width))
            path.lineWidth = 1
            NSGraphicsContext.current!.compositingOperation = NSCompositingOperation.xor
            path.stroke()
        }
    }
    
    private func redrawIfNeeded(rects: [NSRect]) {
        if self.shouldRedraw {
            redraw(rects: rects)
        } else {
            // TODO: remember which rects to draw for later
        }
    }
    
    /// Executes operation without intermediate redraws, only redraw at the end
    public func batchOperations(_ block: () ->()) {
        let oldValue = self.shouldRedraw
        self.shouldRedraw = false
        block()
        self.shouldRedraw = oldValue
        redrawIfNeeded()
    }
    
}

// MARK: - Draw functions
extension ImageLayers {
    
    public func drawLine(from p1: NSPoint, to p2: NSPoint, lineWidth: CGFloat, color: NSColor) {
        self.rasterLayer.lockingFocus {
            restoringGraphicState {
                color.setStroke()
                let path = NSBezierPath()
                path.lineCapStyle = .round
                path.lineJoinStyle = .round
                path.lineWidth = lineWidth
                path.move(to: p1)
                path.line(to: p2)
                path.stroke()
            }
        }
        self.redraw(rects: [NSRect(includingLineFromPoint: p1, toPoint: p2, width: lineWidth)])
    }
    
    public func drawLineMask(from p1: NSPoint, to p2: NSPoint, lineWidth: CGFloat, masked: Bool) {
        self.maskLayer.lockingFocus {
            restoringGraphicState {
                NSColor.black.setStroke()
                NSGraphicsContext.current!.compositingOperation = masked ? .sourceOver : .clear
                let path = NSBezierPath()
                path.lineCapStyle = .round
                path.lineJoinStyle = .round
                path.lineWidth = lineWidth
                path.move(to: p1)
                path.line(to: p2)
                path.stroke()
            }
        }
        self.redraw(rects: [NSRect(includingLineFromPoint: p1, toPoint: p2, width: lineWidth)])
    }
    
    public func drawFullCircle(point: NSPoint, width: CGFloat, color: NSColor) {
        self.rasterLayer.lockingFocus {
            restoringGraphicState {
                color.setFill()
                let source = point - NSPoint(x: width/2, y: width/2)
                let path = NSBezierPath(ovalIn: NSRect(x: source.x, y: source.y, width: width, height: width))
                path.fill()
            }
        }
        self.redraw(rects: [NSRect(squareCenteredOnPoint: point, width: width)])
    }
    
    public func drawFullCircleMask(point: NSPoint, width: CGFloat, masked: Bool) {
        self.maskLayer.lockingFocus {
            restoringGraphicState {
                NSColor.black.setFill()
                NSGraphicsContext.current!.compositingOperation = masked ? .sourceOver : .clear
                let source = point - NSPoint(x: width/2, y: width/2)
                let path = NSBezierPath(ovalIn: NSRect(x: source.x, y: source.y, width: width, height: width))
                path.fill()
            }
        }
        self.redraw(rects: [NSRect(squareCenteredOnPoint: point, width: width)])
    }
    
    public func deleteRaster(point: NSPoint, width: CGFloat) {
        self.rasterLayer.lockingFocus {
            restoringGraphicState {
                NSColor.black.setFill()
                let source = point - NSPoint(x: width/2, y: width/2)
                let path = NSBezierPath(ovalIn: NSRect(x: source.x, y: source.y, width: width, height: width))
                NSGraphicsContext.current!.compositingOperation = NSCompositingOperation.clear
                path.fill()
            }
        }
        self.redraw(rects: [NSRect(squareCenteredOnPoint: point, width: width)])
    }
    
    public func deleteRasterLine(from p1: NSPoint, to p2: NSPoint, width: CGFloat) {
        self.rasterLayer.lockingFocus {
            restoringGraphicState {
                NSColor.black.setFill()
                let path = NSBezierPath()
                path.lineCapStyle = .round
                path.lineJoinStyle = .round
                NSGraphicsContext.current!.compositingOperation = NSCompositingOperation.clear
                path.lineWidth = width
                path.move(to: p1)
                path.line(to: p2)
                path.stroke()
            }
        }
        self.redraw(rects: [NSRect(includingLineFromPoint: p1, toPoint: p2, width: lineWidth)])
    }
        
    public func drawRect(_ rect: NSRect, color: NSColor) {
        self.rasterLayer.lockingFocus {
            restoringGraphicState {
                color.setFill()
                let path = NSBezierPath(rect: rect)
                path.fill()
            }
        }
        self.redraw(rects: [rect])
    }
    
    public func fillMask(masked: Bool) {
        self.maskLayer.lockingFocus {
            restoringGraphicState {
                NSGraphicsContext.current!.compositingOperation = masked ? .sourceOver : .clear
                self.maskLayer.size.toRect.fill()
            }
        }
    }
}

public struct Line: Equatable {
    
    let start: NSPoint
    let end: NSPoint
    let color: NSColor
    let width: CGFloat
    
    public init(start: NSPoint, end: NSPoint, color: NSColor, width: CGFloat) {
        self.start = start
        self.end = end
        self.color = color
        self.width = width
    }
    
    func moveEnd(_ end: NSPoint) -> Line {
        return Line(start: self.start,
                    end: end,
                    color: self.color,
                    width: self.width)
    }
    
    fileprivate func draw() {
        self.color.setStroke()
        let path = NSBezierPath()
        path.lineWidth = width
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.move(to: start)
        path.line(to: end)
        path.stroke()
    }
}


public struct FoilValues {
    static let handleSize: CGFloat = 4.0
    private init() {}
}

extension NSRect {
    
    init(squareCenteredOnPoint center: NSPoint, width: CGFloat) {
        let offset = NSPoint(x: width, y: width)
        self.init(corner: center - offset, oppositeCorner: center + offset)
    }
    
    init(includingLineFromPoint p1: NSPoint, toPoint p2: NSPoint, width: CGFloat) {
        let r1 = NSRect(squareCenteredOnPoint: p1, width: width)
        let r2 = NSRect(squareCenteredOnPoint: p2, width: width)
        
        let maxX = max(r1.maxX, r2.maxX)
        let minX = min(r1.minX, r2.minX)
        let maxY = max(r1.maxY, r2.minY)
        let minY = min(r1.minY, r2.minY)
        
        self.init(corner: NSPoint(x: minX, y: minY), oppositeCorner: NSPoint(x: maxX, y: maxY))
    }
}
