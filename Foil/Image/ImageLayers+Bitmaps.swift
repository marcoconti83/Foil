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

private let bitmapSelectionNotificationName = NSNotification.Name(rawValue: "Foil.bitmapSelectionNotification")
private let selectedBitmapsNotificationKey = "Foil.selectedBitmapsNotificationKey"

private let bitmapSpacing: CGFloat = 10

extension ImageLayers: BitmapContainer {
    
    public func placeNewBitmaps(_ tokens: [ImageToken]) {
        let width = self.renderedImage.size.width
        let bitmaps = tokens.map { (token: ImageToken) -> Bitmap in
            let scale = token.image.size.max / token.maxSize
            return Bitmap(image: token.image, centerPosition: NSPoint.zero, scale: scale, reference: token.reference)
        }
        var x: CGFloat = 0
        var rows = [[Bitmap]]()
        var currentRow = [Bitmap]()
        
        // line up in rows that are not too wide
        bitmaps.forEach { bmp in
            x += bmp.size.width + bitmapSpacing
            if x > width {
                if !currentRow.isEmpty {
                    rows.append(currentRow)
                    currentRow = []
                    x = bmp.halfSize.width + bitmapSpacing
                }
            }
            currentRow.append(bmp.moving(by: NSPoint(x: x, y: 0)))
        }
        
        if !currentRow.isEmpty {
            rows.append(currentRow)
            currentRow = []
        }
        
        // decide row height
        var y: CGFloat = 0
        rows = rows.map { row in
            let maxHeight = row.reduce(CGFloat(0)) { max, bmp in
                return Swift.max(CGFloat(bmp.size.height), max)
            }
            let moved = row.map { bmp in
                bmp.moving(by: NSPoint(x: 0, y: y))
            }
            y = y + maxHeight + 10
            return moved
        }
        
        // add bitmaps
        rows.flatMap { $0 }.forEach {
            self.addBitmap($0.image, centerPosition: $0.centerPosition, scale: $0.scale)
        }
    }
    
    public func selectBitmapByReference(_ references: Set<AnyHashable>, extendSelection: Bool) {
        let previous = extendSelection ? self.selectedBitmaps : Set()
        let selected = self.bitmaps.filter {
            guard let ref = $0.reference else { return false }
            return references.contains(ref)
        }
        self.selectedBitmaps = previous.union(selected)
    }
    
    public func addBitmapSelectionObserver(block: @escaping BitmapSelectionObserver) -> Any {
        return NotificationCenter.default.addObserver(
            forName: bitmapSelectionNotificationName,
            object: self,
            queue: nil)
        { notification in
            guard let bitmaps = notification.userInfo?[selectedBitmapsNotificationKey] as? Set<Bitmap> else {
                return
            }
            block(bitmaps)
        }
    }
    
    func notifySelectionChange() {
        NotificationCenter.default.post(
            name: bitmapSelectionNotificationName,
            object: self,
            userInfo: [selectedBitmapsNotificationKey: self.selectedBitmaps])
    }
}
