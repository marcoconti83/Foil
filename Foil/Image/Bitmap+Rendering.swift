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

extension Bitmap {
    
    func draw() {
        self.image.draw(in: self.imageOnlyRect)
        if let labelImage = self.labelImage {
            labelImage.image.draw(in: labelImage.rectangle)
        }
    }
    
    func drawSelectionOverlay(lineWidth: CGFloat) {
        let borderCountourSize = Swift.max(lineWidth / 2, 0.5)
        let totalBorderSize = borderCountourSize * 2 + lineWidth
        let drawRect = self.imageOnlyRect.expand(by: totalBorderSize / 2)
        restoringGraphicState {
            // main border
            NSColor.red.setStroke()
            NSBezierPath.defaultLineWidth = lineWidth
            NSBezierPath.stroke(drawRect)
            
            // border outer contour
            NSBezierPath.defaultLineWidth = borderCountourSize
            NSColor.white.setStroke()
            NSBezierPath.stroke(drawRect.expand(by: borderCountourSize * 1.5))
            
            // border inner contour
            NSBezierPath.stroke(drawRect.expand(by: -borderCountourSize * 1.5))
            
            // draw handles
            NSColor.red.setStroke()
            NSColor.red.setFill()
            NSBezierPath.defaultLineWidth = lineWidth
            self.corners.forEach {
                let rect = $0.point.asCenterForSquare(size: FoilValues.handleSize)
                NSBezierPath.fill(rect)
                NSBezierPath.stroke(rect)
            }
        }
    }
}
