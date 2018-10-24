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

class SelectionToolTests: XCTestCase {

    func testThatItSelectBitmaps() {
        
        // GIVEN
        let editor = ImageEditor<Int>(emptyImageOfSize: NSSize(width: 100, height: 100))
        editor.toolType = .selection
        let b1 = Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 50, y: 50),
            scale: 0.2
        )
        editor.layers.bitmaps.insert(b1)
        editor.layers.bitmaps.insert(Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 25, y: 50),
            scale: 0.2
        ))
        
        // WHEN
        editor.tool.didMouseDown(NSPoint(x: 55, y: 55), modifierKeys: [])
        editor.tool.didMouseUp(NSPoint(x: 55, y: 55), modifierKeys: [])

        
        // THEN
        XCTAssertEqual(editor.layers.selectedBitmaps, Set([b1]))
    }
    
    func testThatItDeselectBitmaps() {
        
        // GIVEN
        let editor = ImageEditor<Int>(emptyImageOfSize: NSSize(width: 100, height: 100))
        editor.toolType = .selection
        let b1 = Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 50, y: 50),
            scale: 0.2
        )
        editor.layers.bitmaps.insert(b1)
        editor.layers.bitmaps.insert(Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 25, y: 50),
            scale: 0.2
        ))
        editor.layers.selectedBitmaps = Set([b1])
        
        // WHEN
        editor.tool.didMouseDown(NSPoint(x: 10, y: 80), modifierKeys: [])
        editor.tool.didMouseUp(NSPoint(x: 10, y: 80), modifierKeys: [])
        
        // THEN
        XCTAssert(editor.layers.selectedBitmaps.isEmpty)
    }
    
    func testThatItSelectsAnotherBitmap() {
        
        // GIVEN
        let editor = ImageEditor<Int>(emptyImageOfSize: NSSize(width: 100, height: 100))
        editor.toolType = .selection
        let b1 = Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 50, y: 50),
            scale: 0.2
        )
        editor.layers.bitmaps.insert(b1)
        let b2 = Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 25, y: 50),
            scale: 0.2
        )
        editor.layers.bitmaps.insert(b2)
        editor.layers.selectedBitmaps = Set([b1])
        
        // WHEN
        editor.tool.didMouseDown(NSPoint(x: 27, y: 55), modifierKeys: .shift)
        editor.tool.didMouseUp(NSPoint(x: 27, y: 55), modifierKeys: .shift)
        
        // THEN
        XCTAssertEqual(editor.layers.selectedBitmaps, Set([b1, b2]))
    }
    
    func testThatItDeselectsABitmap() {
        
        // GIVEN
        let editor = ImageEditor<Int>(emptyImageOfSize: NSSize(width: 100, height: 100))
        editor.toolType = .selection
        let b1 = Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 50, y: 50),
            scale: 0.2
        )
        editor.layers.bitmaps.insert(b1)
        let b2 = Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 25, y: 50),
            scale: 0.2
        )
        editor.layers.bitmaps.insert(b2)
        editor.layers.selectedBitmaps = Set([b1, b2])
        
        // WHEN
        editor.tool.didMouseDown(NSPoint(x: 27, y: 55), modifierKeys: .shift)
        editor.tool.didMouseUp(NSPoint(x: 27, y: 55), modifierKeys: .shift)
        
        // THEN
        XCTAssertEqual(editor.layers.selectedBitmaps, Set([b1]))
    }
    
    func testThatItDragsABitmap() {
        
        // GIVEN
        let editor = ImageEditor<Int>(emptyImageOfSize: NSSize(width: 100, height: 100))
        editor.toolType = .selection
        let b1 = Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 50, y: 50),
            scale: 0.2
        )
        editor.layers.bitmaps.insert(b1)
        let b2point = NSPoint(x: 25, y: 50)
        editor.layers.bitmaps.insert(Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: b2point,
            scale: 0.2
        ))
        editor.layers.selectedBitmaps = Set([b1])
        let clickOffset = NSPoint(x: 5, y: 5)
        editor.tool.didMouseDown(NSPoint(x: 50, y: 50) + clickOffset, modifierKeys: [])
        
        // WHEN
        let endPoint = NSPoint(x: 20, y: 20)
        editor.tool.didDragMouse(endPoint, modifierKeys: [])
        
        // THEN
        // by moving, bitmaps are replaced with new instances
        XCTAssertEqual(editor.layers.selectedBitmaps.first?.centerPosition, endPoint - clickOffset)
        XCTAssertEqual(
            editor.layers.bitmaps.symmetricDifference(editor.layers.selectedBitmaps).first!.centerPosition,
            b2point
        )
    }
    
    func testThatItDeletesABitmap() {
        
        // GIVEN
        let editor = ImageEditor<Int>(emptyImageOfSize: NSSize(width: 100, height: 100))
        editor.toolType = .selection
        let b1 = Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 50, y: 50),
            scale: 0.2
        )
        let b2 = Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 25, y: 50),
            scale: 0.2
        )
        editor.layers.bitmaps = Set([b1, b2])
        editor.layers.selectedBitmaps = Set([b1])
        
        // WHEN
        XCTAssertTrue(editor.tool.didPressKey(key: .delete, modifierKeys: []))
        
        // THEN
        XCTAssertEqual(editor.layers.selectedBitmaps, Set())
        XCTAssertEqual(editor.layers.bitmaps, [b2])
        
    }
    
    func testThatItStartsPanning() {
        
        // GIVEN
        let editor = ImageEditor<Int>(emptyImageOfSize: NSSize(width: 100, height: 100))
        editor.toolType = .selection
        let b1 = Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 50, y: 50),
            scale: 0.2
        )
        editor.layers.bitmaps.insert(b1)
        editor.layers.selectedBitmaps = Set([b1])
        
        // WHEN
        editor.tool.didMouseDown(NSPoint(x: 0, y: 0), modifierKeys: [])
        
        // THEN
        XCTAssertEqual(editor.toolType, ToolType.pan)
        XCTAssertEqual(editor.layers.selectedBitmaps, Set([b1]))
    }

    func testThatItEndsPanningWithSameSelectedBitmaps() {
        
        // GIVEN
        let editor = ImageEditor<Int>(emptyImageOfSize: NSSize(width: 100, height: 100))
        editor.toolType = .selection
        let b1 = Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 50, y: 50),
            scale: 0.2
        )
        editor.layers.bitmaps = Set([b1])
        editor.layers.selectedBitmaps = Set([b1])
        
        // WHEN
        editor.tool.didMouseDown(NSPoint(x: 0, y: 0), modifierKeys: [])
        editor.tool.didMouseUp(NSPoint(x: 0, y: 0), modifierKeys: [])
        
        // THEN
        XCTAssertEqual(editor.toolType, ToolType.selection)
        XCTAssert(editor.layers.selectedBitmaps.isEmpty)
    }
    
    func testThatItSelectsAll() {
        
        // GIVEN
        let editor = ImageEditor<Int>(emptyImageOfSize: NSSize(width: 100, height: 100))
        editor.toolType = .selection
        let b1 = Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 50, y: 50),
            scale: 0.2
        )
        let b2 = Bitmap<Int>(
            image: Utils.testImage("moon.jpg")!,
            centerPosition: NSPoint(x: 25, y: 50),
            scale: 0.2
        )
        editor.layers.bitmaps = Set([b1, b2])
        editor.layers.selectedBitmaps = Set([])
        
        // WHEN
        XCTAssertTrue(editor.tool.didPressKey(key: .a, modifierKeys: .command))
        
        // THEN
        XCTAssertEqual(editor.layers.selectedBitmaps, Set([b1, b2]))
    }
}

// MARK: - Scale
extension SelectionToolTests {
    
    func testThatItScalesUpBitmapBottomLeft() {
        
        // GIVEN
        let img = Utils.testImage("moon.jpg")!
        let imageCenter = img.size.toPoint / 2
        let editor = ImageEditor<Int>(emptyImageOfSize: NSSize(width: img.size.width * 2, height: img.size.height * 2))
        editor.toolType = .selection
        let canvasCenter = editor.size.toPoint / 2
        let b1 = Bitmap<Int>(
            image: img,
            centerPosition: canvasCenter + imageCenter, // top right quadrant
            scale: 1
        )
        editor.layers.bitmaps.insert(b1)
        
        // WHEN
        let corner = b1.corner(.bottomLeft)
        editor.tool.didMouseDown(corner.point, modifierKeys: [])
        editor.tool.didDragMouse(NSPoint.zero, modifierKeys: [])
        editor.tool.didMouseUp(NSPoint.zero, modifierKeys: [])
        
        // THEN
        guard let bitmap = editor.layers.bitmaps.first else {
            return XCTFail()
        }
        XCTAssertEqual(bitmap.image, img)
        XCTAssertEqual(bitmap.drawingRect.origin, NSPoint.zero)
        XCTAssertEqual(bitmap.drawingRect.size, editor.size)
        XCTAssertEqual(bitmap.scale, 2)
    }
    
    func testThatItScalesUpBitmapBottomRight() {
        
        // GIVEN
        let img = Utils.testImage("moon.jpg")!
        let editor = ImageEditor<Int>(emptyImageOfSize: NSSize(width: img.size.width * 2, height: img.size.height * 2))
        editor.toolType = .selection
        let canvasCenter = editor.size.toPoint / 2
        let imageCenter = img.size.toPoint / 2
        let b1 = Bitmap<Int>(
            image: img,
            centerPosition: canvasCenter.yProjection + imageCenter, // top left quadrant
            scale: 1
        )
        editor.layers.bitmaps.insert(b1)
        
        // WHEN
        let corner = b1.corner(.bottomRight)
        editor.tool.didMouseDown(corner.point, modifierKeys: [])
        editor.tool.didDragMouse(editor.size.toPoint.xProjection, modifierKeys: [])
        editor.tool.didMouseUp(editor.size.toPoint.xProjection, modifierKeys: [])
        
        // THEN
        guard let bitmap = editor.layers.bitmaps.first else {
            return XCTFail()
        }
        XCTAssertEqual(bitmap.image, img)
        XCTAssertEqual(bitmap.drawingRect.origin, NSPoint.zero)
        XCTAssertEqual(bitmap.drawingRect.size, editor.size)
        XCTAssertEqual(bitmap.scale, 2)
    }
    
    func testThatItScalesUpBitmapTopLeft() {
        
        // GIVEN
        let img = Utils.testImage("moon.jpg")!
        let editor = ImageEditor<Int>(emptyImageOfSize: NSSize(width: img.size.width * 2, height: img.size.height * 2))
        editor.toolType = .selection
        let canvasCenter = editor.size.toPoint / 2
        let imageCenter = img.size.toPoint / 2
        let b1 = Bitmap<Int>(
            image: img,
            centerPosition: canvasCenter.xProjection + imageCenter, // bottom right quadrant
            scale: 1
        )
        editor.layers.bitmaps.insert(b1)
        
        // WHEN
        let corner = b1.corner(.topLeft)
        editor.tool.didMouseDown(corner.point, modifierKeys: [])
        editor.tool.didDragMouse(editor.size.toPoint.yProjection, modifierKeys: [])
        editor.tool.didMouseUp(editor.size.toPoint.yProjection, modifierKeys: [])
        
        // THEN
        guard let bitmap = editor.layers.bitmaps.first else {
            return XCTFail()
        }
        XCTAssertEqual(bitmap.image, img)
        XCTAssertEqual(bitmap.drawingRect.origin, NSPoint.zero)
        XCTAssertEqual(bitmap.drawingRect.size, editor.size)
        XCTAssertEqual(bitmap.scale, 2)
    }
    
    func testThatItScalesUpBitmapTopRight() {
        
        // GIVEN
        let img = Utils.testImage("moon.jpg")!
        let editor = ImageEditor<Int>(emptyImageOfSize: NSSize(width: img.size.width * 2, height: img.size.height * 2))
        editor.toolType = .selection
        let imageCenter = img.size.toPoint / 2
        let b1 = Bitmap<Int>(
            image: img,
            centerPosition: imageCenter, // bottom left quadrant
            scale: 1
        )
        editor.layers.bitmaps.insert(b1)
        
        // WHEN
        let corner = b1.corner(.topRight)
        editor.tool.didMouseDown(corner.point, modifierKeys: [])
        editor.tool.didDragMouse(editor.size.toPoint, modifierKeys: [])
        editor.tool.didMouseUp(editor.size.toPoint, modifierKeys: [])
        
        // THEN
        guard let bitmap = editor.layers.bitmaps.first else {
            return XCTFail()
        }
        XCTAssertEqual(bitmap.image, img)
        XCTAssertEqual(bitmap.drawingRect.origin, NSPoint.zero)
        XCTAssertEqual(bitmap.drawingRect.size, editor.size)
        XCTAssertEqual(bitmap.scale, 2)
    }
    
    func testThatItScalesBitmapAtOrigin() {
        
        // GIVEN
        let img = Utils.testImage("moon.jpg")!
        let editor = ImageEditor<Int>(emptyImageOfSize: NSSize(width: img.size.width * 4, height: img.size.height * 4))
        editor.toolType = .selection
        let canvasCenter = editor.size.toPoint / 2
        let b1 = Bitmap<Int>(
            image: img,
            centerPosition: (img.size / 2).toPoint,
            scale: 1
        )
        editor.layers.bitmaps.insert(b1)
        
        // WHEN
        let corner = b1.corner(.topRight)
        editor.tool.didMouseDown(corner.point, modifierKeys: [])
        editor.tool.didDragMouse(canvasCenter, modifierKeys: [])
        editor.tool.didMouseUp(canvasCenter, modifierKeys: [])
        
        // THEN
        guard let bitmap = editor.layers.bitmaps.first else {
            return XCTFail()
        }
        XCTAssertEqual(bitmap.image, img)
        XCTAssertEqual(bitmap.drawingRect.origin, NSPoint.zero)
        XCTAssertEqual(bitmap.drawingRect.size, img.size * 2)
        XCTAssertEqual(bitmap.scale, 2.0)
    }
    
    func testThatItKeepsSelectedfBitmapSelectedWhenScaling() {
        
        // GIVEN
        let img = Utils.testImage("moon.jpg")!
        let editor = ImageEditor<Int>(emptyImageOfSize: NSSize(width: img.size.width * 4, height: img.size.height * 4))
        editor.toolType = .selection
        let canvasCenter = editor.size.toPoint / 2
        let b1 = Bitmap<Int>(
            image: img,
            centerPosition: (img.size / 2).toPoint,
            scale: 1
        )
        editor.layers.bitmaps.insert(b1)
        editor.layers.selectedBitmaps = Set([b1])
        
        // WHEN
        let corner = b1.corner(.topRight)
        editor.tool.didMouseDown(corner.point, modifierKeys: [])
        editor.tool.didDragMouse(canvasCenter, modifierKeys: [])
        editor.tool.didMouseUp(canvasCenter, modifierKeys: [])
        
        // THEN
        XCTAssertNotNil(editor.layers.selectedBitmaps.first)
    }
    
    func testThatItScalesDownBitmapBottomLeft() {
        
        // GIVEN
        let img = Utils.testImage("moon.jpg")!
        let editor = ImageEditor<Int>(emptyImageOfSize: img.size)
        editor.toolType = .selection
        let canvasCenter = editor.size.toPoint / 2
        let b1 = Bitmap<Int>(
            image: img,
            centerPosition: canvasCenter,
            scale: 1
        )
        editor.layers.bitmaps.insert(b1)
        
        // WHEN
        let corner = b1.corner(.bottomLeft)
        editor.tool.didMouseDown(corner.point, modifierKeys: [])
        editor.tool.didDragMouse(canvasCenter, modifierKeys: []) // top right quadrant
        editor.tool.didMouseUp(NSPoint.zero, modifierKeys: [])
        
        // THEN
        guard let bitmap = editor.layers.bitmaps.first else {
            return XCTFail()
        }
        XCTAssertEqual(bitmap.image, img)
        XCTAssertEqual(bitmap.drawingRect.origin, canvasCenter)
        XCTAssertEqual(bitmap.drawingRect.size, editor.size / 2)
        XCTAssertEqual(bitmap.scale, 0.5)
    }
    
    func testThatItScalesDownBitmapBottomRight() {
        
        // GIVEN
        let img = Utils.testImage("moon.jpg")!
        let editor = ImageEditor<Int>(emptyImageOfSize: img.size)
        editor.toolType = .selection
        let canvasCenter = editor.size.toPoint / 2
        let b1 = Bitmap<Int>(
            image: img,
            centerPosition: canvasCenter,
            scale: 1
        )
        editor.layers.bitmaps.insert(b1)
        
        // WHEN
        let corner = b1.corner(.bottomRight)
        editor.tool.didMouseDown(corner.point, modifierKeys: [])
        editor.tool.didDragMouse(canvasCenter, modifierKeys: []) // top left quadrant
        editor.tool.didMouseUp(NSPoint.zero, modifierKeys: [])
        
        // THEN
        guard let bitmap = editor.layers.bitmaps.first else {
            return XCTFail()
        }
        XCTAssertEqual(bitmap.image, img)
        XCTAssertEqual(bitmap.drawingRect.origin, canvasCenter.yProjection)
        XCTAssertEqual(bitmap.drawingRect.size, editor.size / 2)
        XCTAssertEqual(bitmap.scale, 0.5)
    }
    
    func testThatItScalesDownBitmapTopLeft() {
        
        // GIVEN
        let img = Utils.testImage("moon.jpg")!
        let editor = ImageEditor<Int>(emptyImageOfSize: img.size)
        editor.toolType = .selection
        let canvasCenter = editor.size.toPoint / 2
        let b1 = Bitmap<Int>(
            image: img,
            centerPosition: canvasCenter,
            scale: 1
        )
        editor.layers.bitmaps.insert(b1)
        
        // WHEN
        let corner = b1.corner(.topLeft)
        editor.tool.didMouseDown(corner.point, modifierKeys: [])
        editor.tool.didDragMouse(canvasCenter, modifierKeys: []) // bottom right quadrant
        editor.tool.didMouseUp(NSPoint.zero, modifierKeys: [])
        
        // THEN
        guard let bitmap = editor.layers.bitmaps.first else {
            return XCTFail()
        }
        XCTAssertEqual(bitmap.image, img)
        XCTAssertEqual(bitmap.drawingRect.origin, canvasCenter.xProjection)
        XCTAssertEqual(bitmap.drawingRect.size, editor.size / 2)
        XCTAssertEqual(bitmap.scale, 0.5)
    }
    
    func testThatItScalesDownBitmapTopRight() {
        
        // GIVEN
        let img = Utils.testImage("moon.jpg")!
        let editor = ImageEditor<Int>(emptyImageOfSize: img.size)
        editor.toolType = .selection
        let canvasCenter = editor.size.toPoint / 2
        let b1 = Bitmap<Int>(
            image: img,
            centerPosition: canvasCenter,
            scale: 1
        )
        editor.layers.bitmaps.insert(b1)
        
        // WHEN
        let corner = b1.corner(.topRight)
        editor.tool.didMouseDown(corner.point, modifierKeys: [])
        editor.tool.didDragMouse(canvasCenter, modifierKeys: []) // bottom left quadrant
        editor.tool.didMouseUp(NSPoint.zero, modifierKeys: [])
        
        // THEN
        guard let bitmap = editor.layers.bitmaps.first else {
            return XCTFail()
        }
        XCTAssertEqual(bitmap.image, img)
        XCTAssertEqual(bitmap.drawingRect.origin, NSPoint.zero)
        XCTAssertEqual(bitmap.drawingRect.size, editor.size / 2)
        XCTAssertEqual(bitmap.scale, 0.5)
    }
    
    func testThatItScalesBitmapNonUniformlyTopRight() {
        
        // GIVEN
        let img = Utils.testImage("moon.jpg")!
        let editor = ImageEditor<Int>(emptyImageOfSize: img.size)
        editor.toolType = .selection
        let canvasCenter = editor.size.toPoint / 2
        let b1 = Bitmap<Int>(
            image: img,
            centerPosition: canvasCenter,
            scale: 1
        )
        editor.layers.bitmaps.insert(b1)
        
        // WHEN
        let corner = b1.corner(.topRight)
        let endPoint = NSPoint(x: editor.size.width, y: editor.size.height / 2)
        editor.tool.didMouseDown(corner.point, modifierKeys: [])
        editor.tool.didDragMouse(endPoint, modifierKeys: []) // half height
        editor.tool.didMouseUp(endPoint, modifierKeys: [])
        
        // THEN
        guard let bitmap = editor.layers.bitmaps.first else {
            return XCTFail()
        }
        XCTAssertEqual(bitmap.image, img)
        XCTAssertEqual(bitmap.drawingRect.origin, NSPoint.zero)
        XCTAssertEqual(bitmap.drawingRect.size, editor.size / 2)
        XCTAssertEqual(bitmap.scale, 0.5)
    }
    
    func testThatItScalesBitmapNonUniformlyTopLeft() {
        
        // GIVEN
        let img = Utils.testImage("moon.jpg")!
        let editor = ImageEditor<Int>(emptyImageOfSize: img.size)
        editor.toolType = .selection
        let canvasCenter = editor.size.toPoint / 2
        let b1 = Bitmap<Int>(
            image: img,
            centerPosition: canvasCenter,
            scale: 1
        )
        editor.layers.bitmaps.insert(b1)
        
        // WHEN
        let corner = b1.corner(.topLeft)
        let endPoint = NSPoint(x: 0, y: editor.size.height / 2)
        editor.tool.didMouseDown(corner.point, modifierKeys: [])
        editor.tool.didDragMouse(endPoint, modifierKeys: []) // half height
        editor.tool.didMouseUp(endPoint, modifierKeys: [])
        
        // THEN
        guard let bitmap = editor.layers.bitmaps.first else {
            return XCTFail()
        }
        XCTAssertEqual(bitmap.image, img)
        XCTAssertEqual(bitmap.drawingRect.origin, canvasCenter.xProjection)
        XCTAssertEqual(bitmap.drawingRect.size, editor.size / 2)
        XCTAssertEqual(bitmap.scale, 0.5)
    }
    
    func testThatItScalesBitmapNonUniformlyBottomLeft() {
        
        // GIVEN
        let img = Utils.testImage("moon.jpg")!
        let editor = ImageEditor<Int>(emptyImageOfSize: img.size)
        editor.toolType = .selection
        let canvasCenter = editor.size.toPoint / 2
        let b1 = Bitmap<Int>(
            image: img,
            centerPosition: canvasCenter,
            scale: 1
        )
        editor.layers.bitmaps.insert(b1)
        
        // WHEN
        let corner = b1.corner(.bottomLeft)
        let endPoint = NSPoint(x: 0, y: editor.size.height / 2)
        editor.tool.didMouseDown(corner.point, modifierKeys: [])
        editor.tool.didDragMouse(endPoint, modifierKeys: []) // half height
        editor.tool.didMouseUp(endPoint, modifierKeys: [])
        
        // THEN
        guard let bitmap = editor.layers.bitmaps.first else {
            return XCTFail()
        }
        XCTAssertEqual(bitmap.image, img)
        XCTAssertEqual(bitmap.drawingRect.origin, canvasCenter)
        XCTAssertEqual(bitmap.drawingRect.size, editor.size / 2)
        XCTAssertEqual(bitmap.scale, 0.5)
    }
    
    func testThatItScalesBitmapNonUniformlyBottomRight() {
        
        // GIVEN
        let img = Utils.testImage("moon.jpg")!
        let editor = ImageEditor<Int>(emptyImageOfSize: img.size)
        editor.toolType = .selection
        let canvasCenter = editor.size.toPoint / 2
        let b1 = Bitmap<Int>(
            image: img,
            centerPosition: canvasCenter,
            scale: 1
        )
        editor.layers.bitmaps.insert(b1)
        
        // WHEN
        let corner = b1.corner(.bottomRight)
        let endPoint = NSPoint(x: editor.size.width / 2, y: 0)
        editor.tool.didMouseDown(corner.point, modifierKeys: [])
        editor.tool.didDragMouse(endPoint, modifierKeys: []) // half height
        editor.tool.didMouseUp(endPoint, modifierKeys: [])
        
        // THEN
        guard let bitmap = editor.layers.bitmaps.first else {
            return XCTFail()
        }
        XCTAssertEqual(bitmap.image, img)
        XCTAssertEqual(bitmap.drawingRect.origin, NSPoint(x: 0, y: canvasCenter.y))
        XCTAssertEqual(bitmap.drawingRect.size, editor.size / 2)
        XCTAssertEqual(bitmap.scale, 0.5)
    }
}
