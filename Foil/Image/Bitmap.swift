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
import Cocoa

public class Bitmap<Reference: Hashable>: Equatable, Hashable, CustomDebugStringConvertible {
    
    public let image: NSImage
    public let centerPosition: NSPoint
    public let scale: CGFloat
    public let label: String?
    
    /// A custom data reference
    public let reference: Reference?
    
    // --- The following are cached for efficiency
    let originalSize: NSSize
    public let size: NSSize
    let halfSize: NSSize
    let drawingRect: NSRect
    let corners: [Corner]
    let labelImage: ImagePosition?
    // --- end of cache
    
    public init(
        image: NSImage,
        centerPosition: NSPoint = NSPoint(x: 0, y: 0),
        scale: CGFloat = 1,
        label: String? = nil,
        reference: Reference? = nil)
    {
        self.scale = scale
        self.image = image
        self.label = label
        self.centerPosition = centerPosition
        self.originalSize = image.size
        self.size = self.originalSize * scale
        self.halfSize = self.size / 2
        self.reference = reference
        self.drawingRect = NSRect(
            x: self.centerPosition.x - self.halfSize.width,
            y: self.centerPosition.y - self.halfSize.height,
            width: self.size.width,
            height: self.size.height
        )
        self.corners = self.drawingRect.corners
        if let label = label {
            self.labelImage = drawLabel(label: label, bitmapDrawingRect: self.drawingRect)
        } else {
            self.labelImage = nil
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(Unmanaged.passUnretained(self).toOpaque())
    }
    
    public var debugDescription: String {
        return "center: \(self.centerPosition), scale: \(self.scale)"
    }
    
    /// Return a bitmap that is moved to the given point
    public func moving(by offset: NSPoint) -> Bitmap {
        return Bitmap(
            image: self.image,
            centerPosition: self.centerPosition + offset,
            scale: self.scale,
            label: self.label,
            reference: self.reference)
    }
    
    /// Return a bitmap that is scaled by the given factor
    public func scaling(by factor: CGFloat) -> Bitmap {
        return Bitmap(
            image: self.image,
            centerPosition: self.centerPosition,
            scale: self.scale * factor,
            label: self.label,
            reference: self.reference)
    }
    
    func corner(_ direction: Corner.Direction) -> Corner {
        return self.corners.first { $0.direction == direction }!
    }
}

public func ==<T>(lhs: Bitmap<T>, rhs: Bitmap<T>) -> Bool {
    return lhs.scale == rhs.scale && lhs.centerPosition == rhs.centerPosition
        && lhs.image == rhs.image && lhs.reference == rhs.reference
}

extension ImageLayers {
    
    public func replace(originalBitmap: Bitmap<Reference>, newBitmap: Bitmap<Reference>) {
        let wasSelected = self.selectedBitmaps.contains(originalBitmap)
        self.bitmaps.remove(originalBitmap)
        self.bitmaps.insert(newBitmap)
        if wasSelected {
            self.selectedBitmaps.insert(newBitmap)
        }
    }
}

private let paragraphStyle: NSParagraphStyle = {
    let p = NSMutableParagraphStyle()
    p.alignment = .center
    return p
}()

private let stringDrawAttributes = [
    NSAttributedString.Key.foregroundColor: NSColor.black,
    NSAttributedString.Key.backgroundColor: NSColor.white,
    NSAttributedString.Key.font: NSFont.boldSystemFont(ofSize: 20),
    NSAttributedString.Key.paragraphStyle: paragraphStyle
]

private func drawLabel(label: String, bitmapDrawingRect: NSRect) -> ImagePosition {
    let string = label.multilineWithMaxCharactersPerLine(characters: 10) as NSString
    let size = string.size(withAttributes: stringDrawAttributes)
    let image = NSImage(size: NSSize(width: ceil(size.width), height: ceil(size.height)))
    image.lockingFocus {
        string.draw(at: NSPoint.zero, withAttributes: stringDrawAttributes)
    }
    
    let scale = bitmapDrawingRect.size.width / 100
    let finalSize = image.size * scale
    let origin = NSPoint(
        x: bitmapDrawingRect.center.x - finalSize.width / 2,
        y: bitmapDrawingRect.origin.y - finalSize.height
    )
    let belowBitmap = NSRect(origin: origin, size: finalSize)
    
    return ImagePosition(image: image, rectangle: belowBitmap)
}


struct ImagePosition {
    
    let image: NSImage
    let rectangle: NSRect
}
