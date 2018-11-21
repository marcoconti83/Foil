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
            guard oldValue != self.backgroundImage else { return }
            self.redrawIfNeeded(rects: [self.rasterLayer.size.toRect])
        }
    }
    
    /// Background color drawn below the rest
    public var backgroundColor: NSColor = NSColor.white {
        didSet {
            guard oldValue != backgroundColor else { return }
            self.redrawIfNeeded(rects: [self.rasterLayer.size.toRect])
        }
    }
    
    /// Bitmaps objects
    public var bitmaps: Set<Bitmap<Reference>> = Set() {
        didSet {
            guard oldValue != self.bitmaps else { return }
            let newSelection = self.selectedBitmaps.intersection(bitmaps)
            self.batchOperations {
                self.selectedBitmaps = newSelection
            }
        }
    }
    
    /// Bitmaps that are currently selected
    internal(set) public var selectedBitmaps = Set<Bitmap<Reference>>() {
        didSet {
            guard self.selectedBitmaps != oldValue else { return }
            self.redrawIfNeeded(rects: [self.rasterLayer.size.toRect])
            self.notifySelectionChange()
        }
    }
    
    /// Line being drawn
    /// This is a temporary line until it gets confirmed
    var lineBeingDrawn: Line? = nil {
        didSet {
            guard oldValue != self.lineBeingDrawn else { return }
            var rects: [NSRect] = []
            if let oldValue = oldValue {
                rects.append(oldValue.containingRect)
            }
            if let newValue = self.lineBeingDrawn {
                rects.append(newValue.containingRect)
            }
            self.redrawIfNeeded(rects: rects)
        }
    }
    
    var brushPreview: (point: NSPoint, width: CGFloat)? = nil {
        didSet {
            guard oldValue?.point != self.brushPreview?.point
                || oldValue?.width != self.brushPreview?.width
                else { return }
            var rects: [NSRect] = []
            if let oldValue = oldValue {
                rects.append(NSRect.init(squareCenteredOnPoint: oldValue.point, width: oldValue.width))
            }
            if let newValue = self.brushPreview {
                rects.append(NSRect.init(squareCenteredOnPoint: newValue.point, width: newValue.width))
            }
            self.redrawIfNeeded(rects: rects)
        }
    }
    
    /// A layer holding raster data, to be overimposed on background image and color
    let rasterLayer: NSImage
    
    /// A mask layer
    let maskLayer: NSImage
    
    /// Size
    let size: NSSize
    
    /// Rects to redraw
    private var rectsToDraw = [NSRect]()
    
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
        self.size = backgroundImage.size
        self.redraw(rects: [self.rasterLayer.size.toRect])
    }
    
    public init(backgroundImage: NSImage) {
        self.imageBeingEdited = NSImage(emptyClearImageWithSize: backgroundImage.size)
        self.rasterLayer = NSImage(emptyClearImageWithSize: backgroundImage.size)
        self.backgroundImage = backgroundImage
        self.maskLayer = NSImage(emptyClearImageWithSize: backgroundImage.size)
        self.selectionLineWidth = max(1, backgroundImage.size.max / 200)
        self.size = backgroundImage.size
        self.redraw(rects: [self.rasterLayer.size.toRect])
    }
    
}

// MARK: - Redraw
extension ImageLayers {
    
    private func redraw(rects: [NSRect]) {
        self.render(target: self.imageBeingEdited, rect: rects.union, drawForEditing: true)
        self.redrawDelegate?()
    }
    
    private func render(target: NSImage, rect: NSRect, drawForEditing: Bool) {
        target.lockingFocus {
            self.backgroundColor.drawSwatch(in: rect)
            self.backgroundImage.draw(in: rect, from: rect, operation: .sourceOver, fraction: 1)
            self.rasterLayer.draw(in: rect, from: rect, operation: .sourceOver, fraction: 1)
            if drawForEditing {
                self.drawTemporaryLine(rect: rect)
                self.drawTemporaryBrush(rect: rect)
            }
            self.bitmaps.forEach { bmp in
                guard bmp.drawingRect.intersects(rect) else { return }
                bmp.draw()
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
    
    public var renderedImage: NSImage {
        let image = NSImage(size: self.imageBeingEdited.size)
        self.render(target: image, rect: self.imageBeingEdited.size.toRect, drawForEditing: false)
        return image
    }
    
    private func drawTemporaryLine(rect: NSRect) {
        guard let temporaryLine = self.lineBeingDrawn else {
            return
        }
        guard temporaryLine.containingRect.intersects(rect) else { return }
        restoringGraphicState {
            temporaryLine.draw()
        }
    }
    
    private func drawTemporaryBrush(rect: NSRect) {
        guard let brush = self.brushPreview else {
            return
        }
        guard NSRect(squareCenteredOnPoint: brush.point, width: brush.width).intersects(rect) else { return }
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
        guard !rects.isEmpty else { return }
        if self.shouldRedraw {
            redraw(rects: rects)
        } else {
            self.rectsToDraw.append(contentsOf: rects)
        }
    }
    
    /// Executes operation without intermediate redraws, only redraw at the end
    public func batchOperations(_ block: () ->()) {
        let oldValue = self.shouldRedraw
        self.shouldRedraw = false
        block()
        self.shouldRedraw = oldValue
        if self.shouldRedraw {
            drawPending()
        }
    }
    
    /// Draw pending rects and clear pending rects
    private func drawPending() {
        guard !self.rectsToDraw.isEmpty else { return }
        let rect = self.rectsToDraw.union
        self.redrawIfNeeded(rects: [rect])
        self.rectsToDraw = []
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
        self.redraw(rects: [NSRect(includingLineFromPoint: p1, toPoint: p2, width: width)])
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
        let r1 = NSRect(squareCenteredOnPoint: p1, width: width * 2)
        let r2 = NSRect(squareCenteredOnPoint: p2, width: width * 2)
        
        let maxX = max(r1.maxX, r2.maxX)
        let minX = min(r1.minX, r2.minX)
        let maxY = max(r1.maxY, r2.maxY)
        let minY = min(r1.minY, r2.minY)
        
        self.init(corner: NSPoint(x: minX, y: minY), oppositeCorner: NSPoint(x: maxX, y: maxY))
    }
}

extension Line {
    
    var containingRect: NSRect {
        return NSRect(includingLineFromPoint: self.start, toPoint: self.end, width: self.width)
    }
    
}

extension Array where Element == NSRect {
    
    var union: NSRect {
        guard !self.isEmpty else { return NSRect.zero }
        var minX = self[0].minX
        var minY = self[0].minY
        var maxX = self[0].maxX
        var maxY = self[0].maxY
        self.forEach {
            if $0.minX < minX {
                minX = $0.minX
            }
            if $0.maxX > maxX {
                maxX = $0.maxX
            }
            if $0.minY < minY {
                minY = $0.minY
            }
            if $0.maxY < maxY {
                maxY = $0.maxY
            }
        }
        return NSRect(corner: NSPoint(x: minX, y: minY), oppositeCorner: NSPoint(x: maxX, y: maxY))
    }
}
