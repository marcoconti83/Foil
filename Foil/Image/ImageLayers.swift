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
public class ImageLayers {
    
    public let renderResult: NSImage
    
    /// How thick is the selection line width
    let selectionLineWidth: CGFloat
    
    private var shouldRedraw: Bool = true
    
    var redrawDelegate: (()->())? = nil
    
    /// An image to be used as background
    public var backgroundImage: NSImage {
        didSet {
            self.redrawIfNeeded()
        }
    }
    
    /// Background color drawn below the rest
    public var backgroundColor: NSColor = NSColor.white {
        didSet {
            self.redrawIfNeeded()
        }
    }
    
    /// Bitmaps objects
    var bitmaps: Set<Bitmap> = Set() {
        didSet {
            self.redrawIfNeeded()
        }
    }
    
    /// Bitmaps that are currently selected
    internal(set) public var selectedBitmaps = Set<Bitmap>() {
        didSet {
            self.redrawIfNeeded()
        }
    }
    
    /// Line being drawn
    /// This is a temporary line until it gets confirmed
    var lineBeingDrawn: Line? = nil {
        didSet {
            self.redrawIfNeeded()
        }
    }
    
    /// A layer holding raster data, to be overimposed on background image and color
    let rasterLayer: NSImage
    
    public convenience init(emptyImageOfSize size: NSSize) {
        let backgroundImage = NSImage(size: size)
        self.init(backgroundImage: backgroundImage)
    }
    
    public init(backgroundImage: NSImage) {
        self.renderResult = NSImage(size: backgroundImage.size)
        self.rasterLayer = NSImage(size: backgroundImage.size)
        self.backgroundImage = backgroundImage
        self.selectionLineWidth = max(1, backgroundImage.size.max / 200)
        self.redraw()
    }
    
}

// MARK: - Redraw
extension ImageLayers {
    
    private func redraw(rect: NSRect? = nil) {
        let rect = rect ?? NSRect(
            x: 0, y: 0,
            width: self.renderResult.size.width,
            height: self.renderResult.size.height)
        self.renderResult.lockingFocus {
            self.backgroundColor.drawSwatch(in: rect)
            self.backgroundImage.draw(in: rect)
            self.rasterLayer.draw(in: rect)
            self.drawTemporaryLine()
            self.bitmaps.forEach {
                $0.image.draw(in: $0.drawingRect)
                if self.selectedBitmaps.contains($0) {
                    $0.drawSelectionOverlay(lineWidth: self.selectionLineWidth)
                }
            }
        }
        self.redrawDelegate?()
    }
    
    private func drawTemporaryLine() {
        guard let temporaryLine = self.lineBeingDrawn else {
            return
        }
        restoringGraphicState {
            temporaryLine.draw()
        }
    }
    
    private func redrawIfNeeded() {
        if self.shouldRedraw {
            redraw()
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
                path.lineWidth = lineWidth
                path.move(to: p1)
                path.line(to: p2)
                path.stroke()
            }
        }
        self.redraw()
    }
    
    public func drawRect(_ rect: NSRect, color: NSColor) {
        self.rasterLayer.lockingFocus {
            restoringGraphicState {
                color.setFill()
                let path = NSBezierPath(rect: rect)
                path.fill()
            }
        }
        self.redraw()
    }
    
    @discardableResult public func addBitmap(
        _ image: NSImage,
        centerPosition: NSPoint,
        scale: CGFloat = 1
        ) -> Bitmap
    {
        let bitmap = Bitmap(image: image, centerPostion: centerPosition, scale: scale)
        self.bitmaps.insert(bitmap)
        return bitmap
    }

}

extension Bitmap {
    
    fileprivate func drawSelectionOverlay(lineWidth: CGFloat) {
        let borderCountourSize = Swift.max(lineWidth / 2, 0.5)
        let totalBorderSize = borderCountourSize * 2 + lineWidth
        let drawRect = self.drawingRect.expand(by: totalBorderSize / 2)
        restoringGraphicState {
            // main border
            NSColor.red.setStroke()
            NSBezierPath.defaultLineWidth = lineWidth
            NSBezierPath.stroke(drawRect)
            
            // border outer contour
            NSBezierPath.defaultLineWidth = borderCountourSize
            NSColor.white.setStroke()
            NSBezierPath.stroke(drawRect.expand(by: borderCountourSize * 1.5))
            
            // border inner contour
            NSBezierPath.stroke(drawRect.expand(by: -borderCountourSize * 1.5))
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
        path.move(to: start)
        path.line(to: end)
        path.stroke()
    }
}
