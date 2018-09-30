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
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { throw ImageConversionError() }
        return bitmapImage.representation(using: .jpeg, properties: [:])!
    }
    
    public func pngData() throws -> Data {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { throw ImageConversionError() }
        return bitmapImage.representation(using: .png, properties: [:])!
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
    
    convenience init?(name: String) {
        guard let url = Bundle(for: ImageEditorViewController.self).urlForImageResource(name)
            else { return nil }
        self.init(contentsOf: url)
    }
}
