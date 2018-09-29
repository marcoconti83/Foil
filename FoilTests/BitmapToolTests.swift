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
    

import XCTest
@testable import Foil

class BitmapToolTests: XCTestCase {
    
    func testThatItAddsBitmap() {
        
        // GIVEN
        let editor = ImageEditor(emptyImageOfSize: NSSize(width: 100, height: 100))
        let moon = Utils.testImage("moon.jpg")!
        editor.setTool(.bitmap(moon))
        
        // WHEN
        let p = NSPoint(x: 20, y: 20)
        editor.tool.didMouseUp(p, shiftKeyPressed: false)
        
        // THEN
        guard let bitmap = editor.layers.bitmaps.first else {
            return XCTFail()
        }
        XCTAssertEqual(bitmap.centerPosition, p)
        XCTAssertEqual(bitmap.scale, 1)
        XCTAssert(editor.tool is SelectionTool)
    }
    
    func testThatItAddsMultipleBitmaps() {
        
        // GIVEN
        let editor = ImageEditor(emptyImageOfSize: NSSize(width: 100, height: 100))
        let moon = Utils.testImage("moon.jpg")!
        editor.setTool(.bitmap(moon))
        
        // WHEN
        let p = NSPoint(x: 20, y: 20)
        editor.tool.didMouseUp(p, shiftKeyPressed: true)
        
        // THEN
        XCTAssert(editor.tool is BitmapTool)
    }
    
}
