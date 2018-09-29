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

class LineToolTests: XCTestCase {

    func testThatItStartsLine() {
        
        // GIVEN
        let editor = ImageEditor(emptyImageOfSize: NSSize(width: 100, height: 100))
        editor.setTool(.line)
        
        // WHEN
        let p = NSPoint(x: 20, y: 20)
        editor.tool.didTapOnPoint(p, shiftKeyPressed: false)
        
        // THEN
        XCTAssertEqual(editor.layers.lineBeingDrawn, Line(start: p, end: p, color: .black, width: 2))
    }
    
    func testThatItChangesLineColorAndWidth() {
        
        // GIVEN
        let editor = ImageEditor(emptyImageOfSize: NSSize(width: 100, height: 100))
        editor.setTool(.line)
        
        // WHEN
        let p = NSPoint(x: 20, y: 20)
        editor.tool.didTapOnPoint(p, shiftKeyPressed: false)
        editor.toolSettings.color = .red
        editor.toolSettings.lineWidth = 10
        
        // THEN
        XCTAssertEqual(editor.layers.lineBeingDrawn, Line(start: p, end: p, color: .red, width: 10))
    }
    
    func testThatItMovesLine() {
        
        // GIVEN
        let editor = ImageEditor(emptyImageOfSize: NSSize(width: 100, height: 100))
        editor.setTool(.line)
        
        // WHEN
        let p1 = NSPoint(x: 20, y: 20)
        let p2 = NSPoint(x: 85, y: 65)
        editor.tool.didTapOnPoint(p1, shiftKeyPressed: false)
        editor.tool.didMoveMouse(p2)
        
        // THEN
        XCTAssertEqual(editor.layers.lineBeingDrawn, Line(start: p1, end: p2, color: .black, width: 2))
    }
    
    func testThatItEndsLine() {
        
        // GIVEN
        let editor = ImageEditor(emptyImageOfSize: NSSize(width: 100, height: 100))
        editor.setTool(.line)
        
        // WHEN
        let p1 = NSPoint(x: 20, y: 20)
        let p2 = NSPoint(x: 85, y: 65)
        editor.tool.didTapOnPoint(p1, shiftKeyPressed: false)
        editor.tool.didTapOnPoint(p2, shiftKeyPressed: false)
        
        // THEN
        XCTAssertNil(editor.layers.lineBeingDrawn)
        Utils.compareImage(editor.layers.renderResult, fixtureName: "100x100-draw-line.png")
        XCTAssertTrue(editor.tool is SelectionTool)
    }
    
    func testThatItEndsLineAndStartNewOne() {
        
        // GIVEN
        let editor = ImageEditor(emptyImageOfSize: NSSize(width: 100, height: 100))
        editor.setTool(.line)
        
        // WHEN
        let p1 = NSPoint(x: 20, y: 20)
        let p2 = NSPoint(x: 85, y: 65)
        editor.tool.didTapOnPoint(p1, shiftKeyPressed: false)
        editor.tool.didTapOnPoint(p2, shiftKeyPressed: true)
        
        // THEN
        XCTAssertEqual(editor.layers.lineBeingDrawn, Line(start: p2, end: p2, color: .black, width: 2))
        Utils.compareImage(editor.layers.renderResult, fixtureName: "100x100-draw-line.png")
        XCTAssertTrue(editor.tool is LineTool)
    }

}
