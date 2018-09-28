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
import Cocoa

/// Layers that compose the image: background, foreground, vector layer and so on
public class ImageLayers {
    
    public let renderResult: NSImage
    
    /// An image to be used as background
    public var backgroundImage: NSImage? = nil {
        didSet {
            self.redraw()
        }
    }
    
    /// Background color drawn below the rest
    public var backgroundColor: NSColor = NSColor.black {
        didSet {
            self.redraw()
        }
    }
    
    /// A layer holding raster data, to be overimposed on background image and color
    public let rasterLayer: NSImage
    
    init(emptyImageOfSize size: NSSize) {
        self.renderResult = NSImage(size: size)
        self.rasterLayer = NSImage(size: size)
        self.redraw()
    }
    
    init(backgroundImage: NSImage) {
        self.renderResult = NSImage(size: backgroundImage.size)
        self.rasterLayer = NSImage(size: backgroundImage.size)
        self.backgroundImage = backgroundImage
        redraw()
    }
    
    private func redraw() {
        let rect = NSRect(
            x: 0, y: 0,
            width: self.renderResult.size.width,
            height: self.renderResult.size.height)
        self.renderResult.lockFocus()
        self.backgroundColor.drawSwatch(in: rect)
        if let backgroundImage = self.backgroundImage {
            backgroundImage.draw(in: rect)
        }
        self.renderResult.unlockFocus()
    }
    
}
