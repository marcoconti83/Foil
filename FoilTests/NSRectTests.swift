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

class NSRectTests: XCTestCase {
    
    func testRectMidPoint() {
        XCTAssertEqual(NSPoint(x: 0, y: 0).midpoint(to: NSPoint(x: 2, y: 2)), NSPoint(x: 1, y: 1))
        XCTAssertEqual(NSPoint(x: 0, y: 0).midpoint(to: NSPoint(x: 0, y: 0)), NSPoint(x: 0, y: 0))
        XCTAssertEqual(NSPoint(x: 0, y: 0).midpoint(to: NSPoint(x: 2, y: -2)), NSPoint(x: 1, y: -1))
        XCTAssertEqual(NSPoint(x: 10, y: 5).midpoint(to: NSPoint(x: 9, y: 4)), NSPoint(x: 9.5, y: 4.5))
    }
    
    func testRectCenter() {
        XCTAssertEqual(NSRect(x: 0, y: 0, width: 2, height: 4).center, NSPoint(x: 1, y: 2))
        XCTAssertEqual(NSRect(x: 1, y: 1, width: 2, height: 4).center, NSPoint(x: 2, y: 3))
    }
    
    func testRectExpansion() {
        XCTAssertEqual(
            NSRect(x: 0, y: 0, width: 1, height: 1).expand(by: 1),
            NSRect(x: -1, y: -1, width: 3, height: 3)
        )
        XCTAssertEqual(
            NSRect(x: 3, y: 10, width: 10, height: 8).expand(by: 3),
            NSRect(x: 0, y: 7, width: 16, height: 14)
        )
    }
    
    func testMovingCorners() {
        
        let sourceRect = NSRect(x: 10, y: 30, width: 10, height: 20)
        XCTAssertEqual(
            sourceRect.move(corner: .bottomLeft, to: NSPoint(x: 0, y: 5)),
            NSRect(x: 0, y: 5, width: sourceRect.width, height: sourceRect.height)
        )
        XCTAssertEqual(
            sourceRect.move(corner: .bottomRight, to: NSPoint(x: 10, y: 5)),
            NSRect(x: 0, y: 5, width: sourceRect.width, height: sourceRect.height)
        )
        XCTAssertEqual(
            sourceRect.move(corner: .topRight, to: NSPoint(x: 10, y: 25)),
            NSRect(x: 0, y: 5, width: sourceRect.width, height: sourceRect.height)
        )
        XCTAssertEqual(
            sourceRect.move(corner: .topLeft, to: NSPoint(x: 0, y: 25)),
            NSRect(x: 0, y: 5, width: sourceRect.width, height: sourceRect.height)
        )
    }
}
