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
import XCTest
@testable import Foil

private let pseudoRandom1: [CGFloat] = [
    0.03074,
    0.27661,
    0.05980,
    0.15030,
    0.19185,
    0.83495,
    0.57204,
    0.56296,
    0.44880,
    0.11717
]

private let pseudoRandom2: [CGFloat] = [
    0.87537,
    0.11173,
    0.44654,
    0.73247,
    0.73732,
    0.67748,
    0.35822,
    0.85298,
    0.17387,
    0.49211
]

class PerformanceTests: XCTestCase {
    
    func testStaticRendering() {
        
        let layers = ImageLayers<Int>(emptyImageOfSize: NSSize(width: 100, height: 100))
        layers.backgroundColor = NSColor.green
        layers.drawRect(NSRect(x: 10, y: 10, width: 30, height: 30), color: NSColor.white)
        let bitmap = Bitmap<Int>(image: Utils.testImage("moon.jpg")!, centerPosition: NSPoint(x: 100, y: 100))
        layers.bitmaps.insert(bitmap)
        layers.backgroundImage = Utils.testImage("paul-gilmore.jpg")!
        
        self.measure {
            (0...500).forEach { _ in
                _ = layers.renderedImage
            }
        }
    }
    
    func testLineDrawing() {
        
        let layers = ImageLayers<Int>(emptyImageOfSize: NSSize(width: 500, height: 500))
        layers.backgroundColor = NSColor.green
        layers.drawRect(NSRect(x: 10, y: 10, width: 30, height: 30), color: NSColor.white)
        let bitmap = Bitmap<Int>(image: Utils.testImage("moon.jpg")!, centerPosition: NSPoint(x: 100, y: 100))
        layers.bitmaps.insert(bitmap)
        layers.backgroundImage = Utils.testImage("paul-gilmore.jpg")!
        let points = layers.size.pseudoRandomPoints
        
        self.measure {
            points.forEach { p in
                layers.drawLine(
                    from: p,
                    to: p * 2,
                    lineWidth: 50,
                    color: NSColor.red)
            }
        }
    }
    
    func testLinePreview() {
        
        let layers = ImageLayers<Int>(emptyImageOfSize: NSSize(width: 100, height: 100))
        layers.backgroundColor = NSColor.green
        layers.drawRect(NSRect(x: 10, y: 10, width: 30, height: 30), color: NSColor.white)
        let bitmap = Bitmap<Int>(image: Utils.testImage("moon.jpg")!, centerPosition: NSPoint(x: 100, y: 100))
        layers.bitmaps.insert(bitmap)
        layers.backgroundImage = Utils.testImage("paul-gilmore.jpg")!
        let points = layers.size.pseudoRandomPoints
        
        self.measure {
            points.repeated(25).forEach { p in
                layers.lineBeingDrawn = Line(
                    start: p,
                    end: p * 2,
                    color: NSColor.green,
                    width: 100)
            }
        }
    }
    
    func testBrushPreview() {
        
        let layers = ImageLayers<Int>(emptyImageOfSize: NSSize(width: 100, height: 100))
        layers.backgroundColor = NSColor.green
        layers.drawRect(NSRect(x: 10, y: 10, width: 30, height: 30), color: NSColor.white)
        let bitmap = Bitmap<Int>(image: Utils.testImage("moon.jpg")!, centerPosition: NSPoint(x: 100, y: 100))
        layers.bitmaps.insert(bitmap)
        layers.backgroundImage = Utils.testImage("paul-gilmore.jpg")!
        let points = layers.size.pseudoRandomPoints
        
        self.measure {
            points.repeated(50).forEach { p in
                layers.brushPreview = (point: p, width: 10)
            }
        }
    }
    
}


extension NSSize {
    
    var pseudoRandomPoints: [NSPoint] {
        let xPos = pseudoRandom1.map { self.width * $0 }
        let yPos = pseudoRandom2.map { self.height * $0 }
        
        return zip(xPos, yPos).map { NSPoint(x: $0.0, y: $0.1) }
    }
}

extension Array {
    
    func repeated(_ times: Int) -> Array<Element> {
        return (0...times).reduce([Element]()) { prev, _ in
            return prev + self
        }
    }
}
