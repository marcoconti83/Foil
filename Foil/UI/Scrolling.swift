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

/// A clip view that keeps the content in the center rather than in the corner
class CenteredClipView: NSClipView {
    
    override func constrainBoundsRect(_ proposedBounds: NSRect) -> NSRect {
        var rect = super.constrainBoundsRect(proposedBounds)
        if let document = self.documentView {
            
            if (rect.size.width > document.frame.size.width) {
                rect.origin.x = (document.frame.width - rect.width) / 2
            }
            
            if(rect.size.height > document.frame.size.height) {
                rect.origin.y = (document.frame.height - rect.height) / 2
            }
        }
        return rect
    }
}

/// A scroll view that does not allow scrolling with mouse
class ZoomableScrollView: NSScrollView, ScrollDelegate {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.contentView = CenteredClipView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView = CenteredClipView()
    }
    
    override func scrollWheel(with event: NSEvent) {
        if event.deltaY != 0 {
            let magnification = clip(self.magnification + (event.deltaY * 0.1), min: 0.1, max: 20)
            self.magnification = magnification
            return
        }
        self.nextResponder?.scrollWheel(with: event)
    }
    
    func scroll(x: CGFloat, y: CGFloat) {
        let newOrigin = self.contentView.documentVisibleRect.origin + NSPoint(x: x, y: y)
        self.contentView.scroll(to: newOrigin)
    }
}
