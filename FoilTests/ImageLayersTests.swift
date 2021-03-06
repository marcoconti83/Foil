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

import XCTest
@testable import Foil

class ImageLayersTests: XCTestCase {

    func testThatItCreatesAnImageWithOnlyBackground() {
        
        // GIVEN
        let layers = ImageLayers<Int>(emptyImageOfSize: NSSize(width: 50, height: 50))
        
        // WHEN
        layers.backgroundColor = .black
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "100x100-black.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "100x100-black.png")
    }
    
    func testThatItCreatesAnImageWithOnlyBackgroundChangedToRed() {
        
        // GIVEN
        let layers = ImageLayers<Int>(emptyImageOfSize: NSSize(width: 50, height: 50))
        
        // WHEN
        layers.backgroundColor = NSColor.red
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "100x100-red.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "100x100-red.png")
    }
    
    func testThatItCreatesAnImageFromImageWithTransparency() {
        
        // GIVEN
        let layers = ImageLayers<Int>(backgroundImage: Utils.testImage("original-5pepper.png")!)
        
        // WHEN
        layers.backgroundColor = NSColor.blue
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "5pepper.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "5pepper.png")
    }
    
    func testThatItDrawsALine() {
        
        // GIVEN
        let layers = ImageLayers<Int>(emptyImageOfSize: NSSize(width: 50, height: 50))
        layers.backgroundColor = NSColor.red
        
        // WHEN
        layers.drawLine(from: NSPoint(x: 0, y: 0), to: NSPoint(x: 50, y: 50), lineWidth: 5, color: NSColor.green)
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "100x100-red-greenline.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "100x100-red-greenline.png")
    }
    
    func testThatItDrawsARect() {
        
        // GIVEN
        let layers = ImageLayers<Int>(emptyImageOfSize: NSSize(width: 50, height: 50))
        layers.backgroundColor = NSColor.green
        
        // WHEN
        layers.drawRect(NSRect(x: 10, y: 10, width: 30, height: 30), color: NSColor.white)
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "100x100-green-square.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "100x100-green-square.png")
    }
    
    func testThatItDrawsTemporaryLine() {
        
        // GIVEN
        let layers = ImageLayers<Int>(emptyImageOfSize: NSSize(width: 50, height: 50))
        layers.backgroundColor = NSColor.white
        
        // WHEN
        layers.lineBeingDrawn = Line(
            start: NSPoint(x: 13, y: 10),
            end: NSPoint(x: 33, y: 40),
            color: NSColor.red,
            width: 5)
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "100x100-with-line.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "100x100-no-line.png")
    }
    
    func testThatItDrawsBrushPreview() {
        
        // GIVEN
        let layers = ImageLayers<Int>(emptyImageOfSize: NSSize(width: 50, height: 50))
        layers.backgroundColor = NSColor.white
        
        // WHEN
        layers.brushPreview = (point: NSPoint(x: 10, y: 23), width: 5)
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "100x100-with-brush.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "100x100-no-brush.png")
    }
    
    func testThatItReplacesBackgroundImage() {
        
        // GIVEN
        let layers = ImageLayers<Int>(emptyImageOfSize: NSSize(width: 50, height: 100))
        layers.backgroundColor = NSColor.white
        
        // WHEN
        layers.backgroundImage = Utils.testImage("moon.jpg")!
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "50x100-moon-bg.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "50x100-moon-bg.png")
    }
}

// MARK: - Bitmaps
extension ImageLayersTests {
    
    func testThatItDrawsBitmaps() {
        
        // GIVEN
        let layers = ImageLayers<Int>(emptyImageOfSize: NSSize(width: 100, height: 100))
        layers.backgroundColor = NSColor.green
        
        // WHEN
        layers.drawRect(NSRect(x: 10, y: 10, width: 30, height: 30), color: NSColor.white)
        let bitmap = Bitmap<Int>(image: Utils.testImage("moon.jpg")!, centerPosition: NSPoint(x: 100, y: 100))
        layers.bitmaps.insert(bitmap)
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "200x200-green-rect-moon.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "200x200-green-rect-moon.png")
    }
    
    func testThatItDrawsBitmapsWithLabel() {
        
        // GIVEN
        let layers = ImageLayers<Int>(emptyImageOfSize: NSSize(width: 500, height: 500))
        layers.backgroundColor = NSColor.green
        
        // WHEN
        layers.drawRect(NSRect(x: 10, y: 10, width: 30, height: 30), color: NSColor.white)
        let bitmap1 = Bitmap<Int>(image: Utils.testImage("moon.jpg")!,
                            centerPosition: NSPoint(x: 100, y: 300),
                            scale: 1,
                            label: "Test is a very long label!")
        let bitmap2 = Bitmap<Int>(image: Utils.testImage("original-5pepper.png")!,
                                 centerPosition: NSPoint(x: 300, y: 300),
                                 scale: 0.2,
                                 label: "Also a long label for peppers!")
        layers.bitmaps = Set([bitmap1, bitmap2])
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "1000x1000-green-rect-moon-label.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "1000x1000-green-rect-moon-label.png")
    }
    
    func testThatItDrawsBitmapsScaled() {
        
        // GIVEN
        let layers = ImageLayers<Int>(emptyImageOfSize: NSSize(width: 100, height: 100))
        layers.backgroundColor = NSColor.red
        
        // WHEN
        layers.drawLine(from: NSPoint(x: 0, y: 0), to: NSPoint(x: 100, y: 100), lineWidth: 5, color: NSColor.green)
        layers.bitmaps.insert(Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 50, y: 50),
            scale: 0.2
        ))
        layers.bitmaps.insert(Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 25, y: 50),
            scale: 0.2
        ))
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "200x200-red-moons.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "200x200-red-moons.png")
    }
    
    func testThatItDrawsBitmapsSelectedSmall() {
        
        // GIVEN
        let layers = ImageLayers<Int>(emptyImageOfSize: NSSize(width: 100, height: 100))
        layers.backgroundColor = NSColor.white
        layers.bitmaps.insert(Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 50, y: 50),
            scale: 0.2
        ))
        let b2 = Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 25, y: 50),
            scale: 0.2
        )
        layers.bitmaps.insert(b2)
        
        // WHEN
        layers.selectedBitmaps.insert(b2)
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "200x200-red-moons-selected.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "200x200-red-moons-not-selected.png")
    }
    
    func testThatItDrawsBitmapsSelectedLarge() {
        
        // GIVEN
        let layers = ImageLayers<Int>(emptyImageOfSize: NSSize(width: 800, height: 800))
        layers.backgroundColor = NSColor.white
        layers.bitmaps.insert(Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 400, y: 400),
            scale: 0.5
        ))
        let b2 = Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 100, y: 400),
            scale: 0.5
        )
        layers.bitmaps.insert(b2)
        
        // WHEN
        layers.selectedBitmaps.insert(b2)
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "200x200-red-moons-selected-large.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "200x200-red-moons-not-selected-large.png")
    }
    
    func testThatItReplacesBitmapWhenSelected() {
        
        // GIVEN
        let layers = ImageLayers<Int>(emptyImageOfSize: NSSize(width: 100, height: 100))
        layers.backgroundColor = NSColor.white
        let b1 = Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 50, y: 50),
            scale: 0.2
        )
        layers.bitmaps.insert(b1)
        layers.selectedBitmaps.insert(b1)
        
        // WHEN
        layers.replace(originalBitmap: b1, newBitmap: b1.moving(by: NSPoint.zero))
        
        // THEN
        XCTAssertNotNil(layers.selectedBitmaps.first)
    }
}
