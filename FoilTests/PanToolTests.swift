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

class PanToolTests: XCTestCase {
    
    func testThatItSetSelectionTool() {
        
        // GIVEN
        let editor = ImageEditor(emptyImageOfSize: NSSize(width: 100, height: 100))
        editor.toolType = .pan
        
        // WHEN
        editor.tool.didMouseUp(NSPoint(x: 55, y: 55), shiftKeyPressed: false)
        
        // THEN
        XCTAssertEqual(editor.toolType, .selection)
    }
    
    func testThatItPans() {
        
        // GIVEN
        let mockDelegate = MockImageEditorDelegate()
        let editor = ImageEditor(emptyImageOfSize: NSSize(width: 100, height: 100))
        editor.toolType = .pan
        editor.delegate = mockDelegate
        
        // WHEN
        let diff = NSPoint(x: 10, y: 10)
        let initialPoint = NSPoint(x: 0, y: 0)
        editor.tool.didDragMouse(initialPoint)
        editor.tool.didDragMouse(initialPoint + diff)
        
        // THEN
        XCTAssertEqual(editor.toolType, .pan)
        XCTAssertEqual(mockDelegate.scroll.count, 1)
        guard let last = mockDelegate.scroll.last else {
            return XCTFail()
        }
        XCTAssert(last == (-diff.x, -diff.y))
    }
    
}
