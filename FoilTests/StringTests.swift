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

class StringTests: XCTestCase {
    
    func testThatItMakesStringMultiline_ShortString() {
        XCTAssertEqual(
            "12345 78 2345".multilineWithMaxCharactersPerLine(characters: 8),
            "12345 78\n2345")
    }
    
    func testThatItMakesStringMultiline_ShortStringSpaceBefore() {
        XCTAssertEqual(
            "123 567 12345".multilineWithMaxCharactersPerLine(characters: 8),
            "123 567\n12345")
    }
    
    func testThatItMakesStringMultiline_LongString() {
        XCTAssertEqual(
            "This is a string with many characters".multilineWithMaxCharactersPerLine(characters: 8),
            "This is\na string\nwith\nmany\ncharacte\nrs")
    }
    
    func testThatItMakesStringMultiline_empty() {
        XCTAssertEqual(
            "".multilineWithMaxCharactersPerLine(characters: 8),
            "")
    }
    
    func testThatItMakesStringMultiline_SameLength() {
        XCTAssertEqual(
            "12345678".multilineWithMaxCharactersPerLine(characters: 8),
            "12345678")
    }
    
    func testThatItMakesStringMultiline_SameLengthTwice() {
        XCTAssertEqual(
            "1234567812345678".multilineWithMaxCharactersPerLine(characters: 8),
            "12345678\n12345678")
    }
}
