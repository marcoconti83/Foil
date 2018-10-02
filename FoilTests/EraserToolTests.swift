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

class EraserToolTests: XCTestCase {
    
    func testThatItErasesWithoutErasingBackground() {
        
        // GIVEN
        guard let image = Utils.testImage("moon.jpg") else {
            return XCTFail()
        }
        let editor = ImageEditor(backgroundImage: image)
        editor.toolType = .brush
        editor.toolSettings.color = NSColor.red
        editor.toolSettings.lineWidth = 4
        editor.tool.didMouseDown(NSPoint(x: 1, y: 1), shiftKeyPressed: false)
        editor.tool.didDragMouse(NSPoint(x: 50, y: 50))
        editor.tool.didMouseDown(NSPoint(x: 50, y: 50), shiftKeyPressed: false)
        
        // WHEN
        editor.toolType = .eraser
        editor.toolSettings.lineWidth = 20
        editor.tool.didMouseDown(NSPoint(x: 50, y: 1), shiftKeyPressed: false)
        editor.tool.didDragMouse(NSPoint(x: 1, y: 50))
        editor.tool.didMouseUp(NSPoint(x: 1, y: 50), shiftKeyPressed: false)
        
        // THEN
        Utils.compareImage(editor.layers.imageBeingEdited, fixtureName: "100x100-eraser.png")
    }
    
    func testThatItShowsTheEraserOutline() {
        // GIVEN
        let editor = ImageEditor(emptyImageOfSize: NSSize(width: 100, height: 100))
        editor.toolType = .eraser
        editor.toolSettings.lineWidth = 30
        
        // WHEN
        let p = NSPoint(x: 30, y: 10)
        editor.tool.didMoveMouse(p)
        
        // THEN
        Utils.compareImage(editor.layers.imageBeingEdited, fixtureName: "100x100-eraser-outline.png")
        guard let preview = editor.layers.brushPreview else {
            return XCTFail()
        }
        XCTAssert(preview == (point: p, width: 30))
    }
}
