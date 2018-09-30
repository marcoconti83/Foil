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

public func +(lhs: NSPoint, rhs: NSPoint) -> NSPoint {
    return NSPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func -(lhs: NSPoint, rhs: NSPoint) -> NSPoint {
    return NSPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

public func *(lhs: NSPoint, rhs: CGFloat) -> NSPoint {
    return NSPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}

public func /(lhs: NSPoint, rhs: CGFloat) -> NSPoint {
    return NSPoint(x: lhs.x / rhs, y: lhs.y / rhs)
}

public func *(lhs: NSSize, rhs: CGFloat) -> NSSize {
    return NSSize(width: lhs.width * rhs, height: lhs.height * rhs)
}

public func /(lhs: NSSize, rhs: CGFloat) -> NSSize {
    return NSSize(width: lhs.width / rhs, height: lhs.height / rhs)
}

extension NSPoint {

    public func squareDistance(to: NSPoint) -> CGFloat {
        return ((self.x - to.x) * (self.x - to.x)) + ((self.y - to.y) * (self.y - to.y))
    }
    
    public func midpoint(to: NSPoint) -> NSPoint {
        return NSPoint(x: (to.x - self.x)/2, y: (to.y - self.y)/2) + self
    }
    
    public func distance(to: NSPoint) -> CGFloat {
        return sqrt(self.squareDistance(to: to))
    }
}

extension NSRect {
    
    public var center: NSPoint {
        return NSPoint(x: self.midX, y: self.midY)
    }
    
    public func expand(by offset: CGFloat) -> NSRect {
        return NSRect(x: self.minX - offset, y: self.minY - offset,
                      width: self.width + offset*2, height: self.height + offset*2)
    }
}

extension NSSize {
    
    public var min: CGFloat {
        return Swift.min(self.width, self.height)
    }
    
    public var max: CGFloat {
        return Swift.max(self.width, self.height)
    }
}

func clip<T: Comparable>(_ value: T, min: T, max: T) -> T {
    if value < min {
        return min
    }
    if value > max {
        return max
    }
    return value
}
