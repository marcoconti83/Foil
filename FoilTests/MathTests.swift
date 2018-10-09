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
import Foil

class MathTests: XCTestCase {
}

// MARK: - Points
extension MathTests {

    func testPointAddition() {
        XCTAssertEqual(NSPoint(x: 0, y: 0) + NSPoint(x: 4, y: -3), NSPoint(x: 4, y: -3))
        XCTAssertEqual(NSPoint(x: 3, y: -2) + NSPoint(x: 1, y: 2), NSPoint(x: 4, y: 0))
        XCTAssertEqual(NSPoint(x: 0, y: 0) + NSPoint(x: 0, y: 0), NSPoint(x: 0, y: 0))
    }
    
    func testPointSubtraction() {
        XCTAssertEqual(NSPoint(x: 0, y: 0) - NSPoint(x: 4, y: -3), NSPoint(x: -4, y: 3))
        XCTAssertEqual(NSPoint(x: 3, y: -2) - NSPoint(x: 1, y: -2), NSPoint(x: 2, y: 0))
        XCTAssertEqual(NSPoint(x: 0, y: 0) - NSPoint(x: 0, y: 0), NSPoint(x: 0, y: 0))
        XCTAssertEqual(NSPoint(x: 100, y: 10) - NSPoint(x: 100, y: 10), NSPoint(x: 0, y: 0))
    }
    
    func testPointMultiplication() {
        XCTAssertEqual(NSPoint(x: 0, y: 0) * 1, NSPoint(x: 0, y: 0))
        XCTAssertEqual(NSPoint(x: 2, y: -2) * 1, NSPoint(x: 2, y: -2))
        XCTAssertEqual(NSPoint(x: 2, y: -2) * 4, NSPoint(x: 8, y: -8))
        XCTAssertEqual(NSPoint(x: 2, y: -2) * 0, NSPoint(x: 0, y: 0))
        XCTAssertEqual(NSPoint(x: 3, y: 4) * -1, NSPoint(x: -3, y: -4))
    }
    
    func testPointDivision() {
        XCTAssertEqual(NSPoint(x: 0, y: 0) / 2, NSPoint(x: 0, y: 0))
        XCTAssertEqual(NSPoint(x: 2, y: -2) / 2, NSPoint(x: 1, y: -1))
        XCTAssertEqual(NSPoint(x: 2, y: -2) / 4, NSPoint(x: 0.5, y: -0.5))
        XCTAssertEqual(NSPoint(x: 2, y: -2) / 1, NSPoint(x: 2, y: -2))
        XCTAssertEqual(NSPoint(x: 2, y: 4) / -1, NSPoint(x: -2, y: -4))
        XCTAssertEqual(NSPoint(x: 3, y: 4) / 2.5, NSPoint(x: 1.2, y: 1.6))
    }
    
    func testPointSquareDistance() {
        XCTAssertEqual(NSPoint(x: 0, y: 0).squareDistance(to: NSPoint(x: 1, y: 0)), 1)
        XCTAssertEqual(NSPoint(x: 0, y: 0).squareDistance(to: NSPoint(x: 1, y: 1)), 2)
        XCTAssertEqual(NSPoint(x: 0, y: 0).squareDistance(to: NSPoint(x: -1, y: 0)), 1)
        XCTAssertEqual(NSPoint(x: 0, y: 0).squareDistance(to: NSPoint(x: 1, y: -1)), 2)
        XCTAssertEqual(NSPoint(x: 2, y: 4).squareDistance(to: NSPoint(x: 0, y: 2)), 8)
        XCTAssertEqual(NSPoint(x: 2, y: 4).squareDistance(to: NSPoint(x: 2, y: 2)), 4)
    }
    
    func testPointDistance() {
        XCTAssertEqual(NSPoint(x: 0, y: 0).distance(to: NSPoint(x: 1, y: 0)), 1)
        XCTAssertEqual(NSPoint(x: 0, y: 0).distance(to: NSPoint(x: 4, y: -3)), 5)
        XCTAssertEqual(NSPoint(x: 0, y: 0).distance(to: NSPoint(x: -1, y: 0)), 1)
        XCTAssertEqual(NSPoint(x: 2, y: 4).distance(to: NSPoint(x: 2, y: 2)), 2)
    }
}

