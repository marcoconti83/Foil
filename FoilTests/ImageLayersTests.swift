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
        let layers = ImageLayers(emptyImageOfSize: NSSize(width: 50, height: 50))
        
        // WHEN
        layers.backgroundColor = .black
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "100x100-black.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "100x100-black.png")
    }
    
    func testThatItCreatesAnImageWithOnlyBackgroundChangedToRed() {
        
        // GIVEN
        let layers = ImageLayers(emptyImageOfSize: NSSize(width: 50, height: 50))
        
        // WHEN
        layers.backgroundColor = NSColor.red
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "100x100-red.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "100x100-red.png")
    }
    
    func testThatItCreatesAnImageFromImageWithTransparency() {
        
        // GIVEN
        let layers = ImageLayers(backgroundImage: Utils.testImage("original-5pepper.png")!)
        
        // WHEN
        layers.backgroundColor = NSColor.blue
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "5pepper.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "5pepper.png")
    }
    
    func testThatItDrawsALine() {
        
        // GIVEN
        let layers = ImageLayers(emptyImageOfSize: NSSize(width: 50, height: 50))
        layers.backgroundColor = NSColor.red
        
        // WHEN
        layers.drawLine(from: NSPoint(x: 0, y: 0), to: NSPoint(x: 50, y: 50), lineWidth: 5, color: NSColor.green)
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "100x100-red-greenline.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "100x100-red-greenline.png")
    }
    
    func testThatItDrawsARect() {
        
        // GIVEN
        let layers = ImageLayers(emptyImageOfSize: NSSize(width: 50, height: 50))
        layers.backgroundColor = NSColor.green
        
        // WHEN
        layers.drawRect(NSRect(x: 10, y: 10, width: 30, height: 30), color: NSColor.white)
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "100x100-green-square.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "100x100-green-square.png")
    }
    
    func testThatItDrawsBitmaps() {
        
        // GIVEN
        let layers = ImageLayers(emptyImageOfSize: NSSize(width: 100, height: 100))
        layers.backgroundColor = NSColor.green
        
        // WHEN
        layers.drawRect(NSRect(x: 10, y: 10, width: 30, height: 30), color: NSColor.white)
        _ = layers.addBitmap(Utils.testImage("moon.jpg")!, centerPosition: NSPoint(x: 100, y: 100))
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "200x200-green-rect-moon.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "200x200-green-rect-moon.png")
    }
    
    func testThatItDrawsBitmapsScaled() {
        
        // GIVEN
        let layers = ImageLayers(emptyImageOfSize: NSSize(width: 100, height: 100))
        layers.backgroundColor = NSColor.red
        
        // WHEN
        layers.drawLine(from: NSPoint(x: 0, y: 0), to: NSPoint(x: 100, y: 100), lineWidth: 5, color: NSColor.green)
        layers.addBitmap(
            Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 50, y: 50),
            scale: 0.2
        )
        layers.addBitmap(
            Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 25, y: 50),
            scale: 0.2
        )
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "200x200-red-moons.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "200x200-red-moons.png")
    }
    
    func testThatItDrawsBitmapsSelectedSmall() {
        
        // GIVEN
        let layers = ImageLayers(emptyImageOfSize: NSSize(width: 100, height: 100))
        layers.backgroundColor = NSColor.white
        layers.addBitmap(
            Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 50, y: 50),
            scale: 0.2
        )
        let b2 = layers.addBitmap(
            Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 25, y: 50),
            scale: 0.2
        )
        
        // WHEN
        layers.selectedBitmaps.insert(b2)
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "200x200-red-moons-selected.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "200x200-red-moons-not-selected.png")
    }
    
    func testThatItDrawsBitmapsSelectedLarge() {
        
        // GIVEN
        let layers = ImageLayers(emptyImageOfSize: NSSize(width: 800, height: 800))
        layers.backgroundColor = NSColor.white
        layers.addBitmap(
            Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 400, y: 400),
            scale: 0.5
        )
        let b2 = layers.addBitmap(
            Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 100, y: 400),
            scale: 0.5
        )
        
        // WHEN
        layers.selectedBitmaps.insert(b2)
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "200x200-red-moons-selected-large.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "200x200-red-moons-not-selected-large.png")
    }
    
    func testThatItDoesDrawTemporaryLine() {
        
        // GIVEN
        let layers = ImageLayers(emptyImageOfSize: NSSize(width: 50, height: 50))
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
        let layers = ImageLayers(emptyImageOfSize: NSSize(width: 50, height: 50))
        layers.backgroundColor = NSColor.white
        
        // WHEN
        layers.brushPreview = (point: NSPoint(x: 10, y: 23), width: 5)
        
        // THEN
        Utils.compareImage(layers.imageBeingEdited, fixtureName: "100x100-with-brush.png")
        Utils.compareImage(layers.renderedImage, fixtureName: "100x100-no-brush.png")
    }
}
