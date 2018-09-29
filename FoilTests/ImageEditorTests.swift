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

class ImageEditorTests: XCTestCase {
}

// MARK: - Bitmaps
extension ImageEditorTests {

    func testThatItSelectBitmaps() {
        
        // GIVEN
        let editor = ImageEditor(emptyImageOfSize: NSSize(width: 100, height: 100))
        let b1 = editor.layers.addBitmap(
            Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 50, y: 50),
            scale: 0.2
        )
        editor.layers.addBitmap(
            Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 25, y: 50),
            scale: 0.2
        )
        
        // WHEN
        editor.didTapOnPoint(NSPoint(x: 55, y: 55), shiftKeyPressed: false)
        
        // THEN
        XCTAssertEqual(editor.layers.selectedBitmaps, Set([b1]))
    }
    
    func testThatItDeselectBitmaps() {
        
        // GIVEN
        let editor = ImageEditor(emptyImageOfSize: NSSize(width: 100, height: 100))
        let b1 = editor.layers.addBitmap(
            Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 50, y: 50),
            scale: 0.2
        )
        editor.layers.addBitmap(
            Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 25, y: 50),
            scale: 0.2
        )
        editor.layers.selectedBitmaps = Set([b1])
        
        // WHEN
        editor.didTapOnPoint(NSPoint(x: 10, y: 80), shiftKeyPressed: false)
        
        // THEN
        XCTAssert(editor.layers.selectedBitmaps.isEmpty)
    }
    
    func testThatItSelectsAnotherBitmap() {
        
        // GIVEN
        let editor = ImageEditor(emptyImageOfSize: NSSize(width: 100, height: 100))
        let b1 = editor.layers.addBitmap(
            Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 50, y: 50),
            scale: 0.2
        )
        let b2 = editor.layers.addBitmap(
            Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 25, y: 50),
            scale: 0.2
        )
        editor.layers.selectedBitmaps = Set([b1])
        
        // WHEN
        editor.didTapOnPoint(NSPoint(x: 27, y: 55), shiftKeyPressed: true)
        
        // THEN
        XCTAssertEqual(editor.layers.selectedBitmaps, Set([b1, b2]))
    }
    
    func testThatItDeselectsABitmap() {
        
        // GIVEN
        let editor = ImageEditor(emptyImageOfSize: NSSize(width: 100, height: 100))
        let b1 = editor.layers.addBitmap(
            Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 50, y: 50),
            scale: 0.2
        )
        let b2 = editor.layers.addBitmap(
            Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 25, y: 50),
            scale: 0.2
        )
        editor.layers.selectedBitmaps = Set([b1, b2])
        
        // WHEN
        editor.didTapOnPoint(NSPoint(x: 27, y: 55), shiftKeyPressed: true)
        
        // THEN
        XCTAssertEqual(editor.layers.selectedBitmaps, Set([b1]))
    }
    
    func testThatItDeletesABitmap() {
        
        // GIVEN
        let editor = ImageEditor(emptyImageOfSize: NSSize(width: 100, height: 100))
        let b1 = editor.layers.addBitmap(
            Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 50, y: 50),
            scale: 0.2
        )
        let b2 = editor.layers.addBitmap(
            Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 25, y: 50),
            scale: 0.2
        )
        editor.layers.selectedBitmaps = Set([b1])
        
        // WHEN
        editor.didPressKey(key: .delete)
        
        // THEN
        XCTAssertEqual(editor.layers.selectedBitmaps, Set())
        XCTAssertEqual(editor.layers.bitmaps, [b2])
        
    }

}

// MARK: - Temporary line
extension ImageEditorTests {
    
}
