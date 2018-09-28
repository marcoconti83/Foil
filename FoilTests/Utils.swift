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
import XCTest

class Utils {
    
    private init() {}
    
    static func testImage(_ fileName: String) -> NSImage {
        
        let ext = (fileName as NSString).pathExtension
        let name = (fileName as NSString).deletingPathExtension
        
        guard let URL = Bundle(for: Utils.self).url(forResource: name, withExtension: ext) else {
            fatalError("File \(fileName) not found in test bundle")
        }
        guard let image = NSImage(contentsOf: URL) else {
            fatalError("Can't read image \(fileName) in test bundle")
        }
        return image
    }
    
    static func compareImage(
        _ image: NSImage,
        fixtureName: String,
        file: StaticString = #file,
        line: UInt = #line)
    {
        let png = try! image.pngData()
        //saveFixtures(data: png, name: fixtureName)
        XCTAssertEqual(png, try! Utils.testImage(fixtureName).pngData(), "Images don't match", file: file, line: line)
        
    }
}

private func saveFixtures(data: Data, name: String) {
    var root: URL = URL(fileURLWithPath: NSHomeDirectory())
    if let rawValue = getenv("source_path"),
        let string = String(utf8String: rawValue)
    {
        root = URL(fileURLWithPath: string).appendingPathComponent("FoilTests/Resources/")
    }
    let url = root.appendingPathComponent("Fixtures/" + name)
    try! data.write(to: url)
}
