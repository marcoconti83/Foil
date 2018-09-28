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

class FoilTests: XCTestCase {

    func testThatItCreatesAnImageWithOnlyBackground() {
        
        // GIVEN
        let layers = ImageLayers(emptyImageOfSize: NSSize(width: 50, height: 50))
        
        // WHEN
        let image = layers.finalImage        
        
        // THEN
        Utils.compareImage(image, fixtureName: "100x100-black.png")
    }
    
    func testThatItCreatesAnImageWithOnlyBackgroundChangedToRed() {
        
        // GIVEN
        let layers = ImageLayers(emptyImageOfSize: NSSize(width: 50, height: 50))
        
        // WHEN
        layers.backgroundColor = NSColor.red
        let image = layers.finalImage
        
        // THEN
        Utils.compareImage(image, fixtureName: "100x100-red.png")
    }
    
    func testThatItCreatesAnImageFromImageWithTransparency() {
        
        // GIVEN
        let layers = ImageLayers(backgroundImage: Utils.testImage("original-5pepper.png"))
        layers.backgroundColor = NSColor.blue
        
        // WHEN
        let image = layers.finalImage
        
        // THEN
        Utils.compareImage(image, fixtureName: "5pepper.png")
    }

}
