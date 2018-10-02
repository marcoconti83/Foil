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

class BrushToolTests: XCTestCase {
    
    func testThatItDrawsWithBrush() {
        
        // GIVEN
        let editor = ImageEditor(emptyImageOfSize: NSSize(width: 100, height: 100))
        editor.toolType = .brush
        editor.toolSettings.color = NSColor.red
        editor.toolSettings.lineWidth = 2
        
        // WHEN
        editor.tool.didMouseDown(NSPoint(x: 5, y: 5), shiftKeyPressed: false)
        editor.tool.didDragMouse(NSPoint(x: 5, y: 15))
        editor.tool.didDragMouse(NSPoint(x: 14, y: 30))
        editor.tool.didDragMouse(NSPoint(x: 22, y: 18))
        
        // THEN
        Utils.compareImage(editor.layers.imageBeingEdited, fixtureName: "100x100-brush.png")
    }
}
