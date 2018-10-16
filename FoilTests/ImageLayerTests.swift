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

class ImageLayerTests: XCTestCase {
    
    func testThatItNotifiesOfBitmapSelection() {
        
        // GIVEN
        let img = Utils.testImage("moon.jpg")!
        let editor = ImageLayers(emptyImageOfSize: img.size)
        let canvasCenter = editor.renderedImage.size.toPoint / 2
        let b1 = editor.addBitmap(
            img,
            centerPosition: canvasCenter,
            scale: 1
        )
        var recordedNotifications = [Set<Bitmap>]()
        let observerToken = editor.addBitmapSelectionObserver() { selection in
            recordedNotifications.append(selection)
        }
        
        // WHEN
        editor.selectedBitmaps = Set([b1])
        editor.selectedBitmaps = Set()
        
        // THEN
        XCTAssertEqual(recordedNotifications.first, Set([b1]))
        XCTAssertEqual(recordedNotifications.last, Set([]))
        XCTAssertEqual(recordedNotifications.count, 2)
        XCTAssertNotNil(observerToken)
    }
    
    func testThatItSelectBitmapByReference() {
        
        // GIVEN
        let img = Utils.testImage("moon.jpg")!
        let editor = ImageLayers(emptyImageOfSize: img.size)
        let canvasCenter = editor.renderedImage.size.toPoint / 2
        let uuid = UUID()
        let b1 = Bitmap(
            image: img,
            centerPosition: canvasCenter,
            scale: 1,
            reference: uuid
        )
        let b2 = Bitmap(
            image: img,
            centerPosition: canvasCenter,
            scale: 1,
            reference: UUID()
        )
        editor.bitmaps = Set([b1, b2])
        
        // WHEN
        editor.selectBitmapByReference(Set([uuid]), extendSelection: false)
        
        // THEN
        XCTAssertEqual(editor.selectedBitmaps, Set([b1]))
    }
}
