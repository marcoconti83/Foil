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

public struct ImageConversionError: Error {}

extension NSImage {
    
    /// Returns a JPEG reprentation of self
    public func jpgData() throws -> Data {
        let cgref = self.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let rep = NSBitmapImageRep(cgImage: cgref)
        rep.size = self.size
        return rep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
    }
    
    public func pngData() throws -> Data {
        let cgref = self.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let rep = NSBitmapImageRep(cgImage: cgref)
        rep.size = self.size
        return rep.representation(using: NSBitmapImageRep.FileType.png, properties: [:])!
    }
    
    /// Writes a JPEG representation of self to a URL
    public func jpgWrite(to url: URL, options: Data.WritingOptions = .atomic) throws {
        let data = try self.jpgData()
        try data.write(to: url, options: options)
    }
    
    /// Writes a JPEG representation of self to a URL
    public func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) throws {
        let data = try self.pngData()
        try data.write(to: url, options: options)
    }
}

extension NSImage {
    
    public convenience init?(name: String, fromClassBundle aClass: AnyClass) {
        guard let url = Bundle(for: aClass).urlForImageResource(name)
            else { return nil }
        self.init(contentsOf: url)
    }
}

extension NSImage {
    
    convenience init(emptyClearImageWithSize size: NSSize) {
        self.init(size: size)
        self.lockingFocus {
            size.toRect.fill(using: .clear)
        }
    }

    public func resized(size: NSSize) -> NSImage {
        let intSize = NSSize(width: Int(size.width), height: Int(size.height))
        let cgImage = self.cgImage!
        let context = CGContext(data: nil,
                                width: Int(intSize.width),
                                height: Int(intSize.height),
                                bitsPerComponent: cgImage.bitsPerComponent,
                                bytesPerRow: 0,
                                space: cgImage.colorSpace!,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
        
        context.interpolationQuality = .high
        context.draw(cgImage,
                     in: NSRect(x: 0, y: 0, width: intSize.width, height: intSize.height))
        let img = context.makeImage()!
        return NSImage(cgImage: img, size: intSize)
    }

    
    var cgImage: CGImage? {
        get {
            guard let imageData = self.tiffRepresentation else { return nil }
            guard let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
            return CGImageSourceCreateImageAtIndex(sourceData, 0, nil)
        }
    }
}
