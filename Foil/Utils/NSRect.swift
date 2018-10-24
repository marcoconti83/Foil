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

extension NSRect {
    
    public var center: NSPoint {
        return NSPoint(x: self.midX, y: self.midY)
    }
    
    public func expand(by offset: CGFloat) -> NSRect {
        return NSRect(x: self.minX - offset, y: self.minY - offset,
                      width: self.width + offset*2, height: self.height + offset*2)
    }
    
    public var corners: [Corner] {
        return Corner.Direction.all.map { d in
            let point = NSPoint(x: self.minX + self.width * d.normalizedOffsetToSource.x,
                           y: self.minY + self.height * d.normalizedOffsetToSource.y)
            return Corner(point: point, direction: d)
        }
    }
    
    // Returns a rect scaled to include the new corner in place of the old one
    public func scaleToCorner(_ corner: Corner) -> NSRect {
        let old = self.corners.first { $0.direction == corner.direction }!
        guard old.point != corner.point else { return self }
        return NSRect(corner: corner.point, oppositeCorner: self.corner(corner.direction.opposite).point)
    }
    
    // Move the rect so that the corner matches the point
    public func move(corner: Corner.Direction, to fixedPoint: NSPoint) -> NSRect {
        switch corner {
        case .topRight:
            return NSRect(origin: fixedPoint - self.size.toPoint, size: self.size)
        case .topLeft:
            return NSRect(origin: NSPoint(x: fixedPoint.x, y: fixedPoint.y - self.height),
                          size: self.size)
        case .bottomLeft:
            return NSRect(origin: fixedPoint, size: self.size)
        case .bottomRight:
            return NSRect(origin: NSPoint(x: fixedPoint.x - self.width, y: fixedPoint.y), size: self.size)
        }
    }
    
    public func corner(_ direction: Corner.Direction) -> Corner {
        return self.corners.first { $0.direction == direction }!
    }
    
    init(corner: NSPoint, oppositeCorner: NSPoint) {
        let minX = min(corner.x, oppositeCorner.x)
        let maxX = max(corner.x, oppositeCorner.x)
        let minY = min(corner.y, oppositeCorner.y)
        let maxY = max(corner.y, oppositeCorner.y)
        self.init(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

/// Translate origin
public func+(lhs: NSRect, rhs: NSPoint) -> NSRect {
    return NSRect(origin: lhs.origin + rhs, size: lhs.size)
}

extension NSPoint {
    
    /// Creates a square of the given size centered on this point
    public func asCenterForSquare(size: CGFloat) -> NSRect {
        let half = size / 2.0;
        return NSRect(x: self.x - half, y: self.y - half, width: size, height: size)
    }
}

// A corner of a rectangle
public struct Corner {
    
    public enum Direction {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        
        public var normalizedOffsetToSource: NSPoint {
            switch self {
            case .topLeft:
                return NSPoint(x: 0.0, y: 1.0)
            case .topRight:
                return NSPoint(x: 1.0, y: 1.0)
            case .bottomLeft:
                return NSPoint(x: 0.0, y: 0.0)
            case .bottomRight:
                return NSPoint(x: 1.0, y: 0.0)
            }
        }
        
        public var opposite: Direction {
            switch self {
            case .topLeft:
                return .bottomRight
            case .topRight:
                return .bottomLeft
            case .bottomLeft:
                return .topRight
            case .bottomRight:
                return .topLeft
            }
        }
        
        public static let all: [Direction] = [.topRight, .topLeft, .bottomLeft, .bottomRight]
    }
    
    public let point: NSPoint
    public let direction: Direction
}

extension NSSize {
    
    var toRect: NSRect {
        return NSRect(origin: NSPoint.zero, size: self)
    }
}
