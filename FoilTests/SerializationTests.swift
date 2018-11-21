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

class SerializationTests: XCTestCase {
    
    func testThatItSerializesImage() throws {
        
        // GIVEN
        let size = NSSize(width: 200, height: 200)
        let layers = ImageLayers<UUID>(backgroundImage: NSImage(emptyClearImageWithSize: size))
        layers.backgroundColor = .white // use grayscale color, known to cause problem when extracting RGB
        
        // WHEN
        let data = try layers.encode()
        let decoded = try ImageLayers<UUID>.decodingData(data: data)
        
        // THEN
        XCTAssertEqual(decoded.size, layers.size)
        
    }
    
    func testThatItSerializesBitmap() throws {
        
        // GIVEN
        let layers = ImageLayers<String>(backgroundImage: Utils.testImage("original-5pepper.png")!)
        let bitmap = Bitmap(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 400, y: 234),
            scale: 0.45,
            label: "Jonny",
            reference: "Foobar")
        layers.bitmaps = Set([bitmap])
        layers.drawLine(
            from: NSPoint.zero,
            to: NSPoint(x: 300, y: 200),
            lineWidth: 10,
            color: NSColor.red)
        layers.backgroundColor = NSColor.green
        layers.drawLineMask(from: NSPoint(x: 0, y: 100), to: NSPoint.zero, lineWidth: 40, masked: true)
        
        // WHEN
        let data = try layers.encode()
        let decoded = try ImageLayers<String>.decodingData(data: data)
        
        // THEN
        XCTAssertEqual(try! decoded.renderedImage.pngData(), try! layers.renderedImage.pngData())
        XCTAssertEqual(decoded.bitmaps.count, 1)
        XCTAssert(bitmap.isEqualWithPngImage(bitmap: decoded.bitmaps.first))
        XCTAssertEqual(try! decoded.rasterLayer.pngData(), try! layers.rasterLayer.pngData())
        XCTAssertEqual(try! decoded.maskLayer.pngData(), try! layers.maskLayer.pngData())
        XCTAssertEqual(try! decoded.imageBeingEdited.pngData(), try! layers.imageBeingEdited.pngData())
        XCTAssertEqual(decoded.backgroundColor, layers.backgroundColor)
        XCTAssertEqual(try! decoded.backgroundImage.pngData(), try! layers.backgroundImage.pngData())
    }
}

extension Bitmap {
    
    func isEqualWithPngImage(bitmap: Bitmap<Reference>?) -> Bool {
        guard let bitmap = bitmap else { return false }
        return bitmap.centerPosition == self.centerPosition
            && bitmap.scale == self.scale
            && (try! bitmap.image.pngData()) == (try! self.image.pngData())
            && bitmap.reference == self.reference
            && bitmap.label == self.label
    }
}
