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

public final class Bitmap: Equatable, Hashable, CustomDebugStringConvertible {
    
    private let uuid: UUID = UUID()
    
    let image: NSImage
    let centerPosition: NSPoint
    let scale: CGFloat
    
    let originalSize: NSSize
    let size: NSSize
    let halfSize: NSSize
    let drawingRect: NSRect
    
    init(
        image: NSImage,
        centerPostion: NSPoint = NSPoint(x: 0, y: 0),
        scale: CGFloat = 1)
    {
        self.scale = scale
        self.image = image
        self.centerPosition = centerPostion
        self.originalSize = image.size
        self.size = self.originalSize * scale
        self.halfSize = self.size / 2
        self.drawingRect = NSRect(
            x: self.centerPosition.x - self.halfSize.width,
            y: self.centerPosition.y - self.halfSize.height,
            width: self.size.width,
            height: self.size.height
        )
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(Unmanaged.passUnretained(self).toOpaque())
    }
    
    public var debugDescription: String {
        return "center: \(self.centerPosition), scale: \(self.scale)"
    }
}

public func ==(lhs: Bitmap, rhs: Bitmap) -> Bool {
    return lhs.scale == rhs.scale && lhs.centerPosition == rhs.centerPosition
        && lhs.image === rhs.image
}
