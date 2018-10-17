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

public struct ImageDecodingError: Error {}

/// A bitmap that can be serialized
private class BitmapSerializableWrapper<T: Hashable & Codable>: Codable {
    
    enum CodingKeys: CodingKey {
        case image
        case centerPosition
        case scale
        case reference
    }
    
    let bitmap: Bitmap<T>
    
    init(bitmap: Bitmap<T>) {
        self.bitmap = bitmap
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let image = try container.decodeImageByData(forKey: CodingKeys.image)
        let centerPosition = try container.decode(NSPoint.self, forKey: CodingKeys.centerPosition)
        let scale = try container.decode(CGFloat.self, forKey: CodingKeys.scale)
        let reference = try container.decodeIfPresent(T.self, forKey: CodingKeys.reference)
        self.bitmap = Bitmap(image: image, centerPosition: centerPosition, scale: scale, reference: reference)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.bitmap.image, forKey: CodingKeys.image)
        try container.encode(self.bitmap.scale, forKey: CodingKeys.scale)
        try container.encode(self.bitmap.centerPosition, forKey: CodingKeys.centerPosition)
        try container.encode(self.bitmap.reference, forKey: CodingKeys.reference)
    }
}

private class ImageLayersSerializableWrapper<T: Hashable & Codable>: Codable {
    
    enum CodingKeys: CodingKey {
        case backgroundImage
        case backgroundColor
        case rasterLayer
        case maskLayer
        case bitmaps
    }
    
    let imageLayers: ImageLayers<T>
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rasterLayer = try container.decodeImageByData(forKey: CodingKeys.rasterLayer)
        let maskLayer = try container.decodeImageByData(forKey: CodingKeys.maskLayer)
        let backgroundImage = try container.decodeImageByData(forKey: CodingKeys.backgroundImage)
        let backgroundColor = try container.decodeColor(forKey: CodingKeys.backgroundColor)
        let bitmaps = try container.decode([BitmapSerializableWrapper<T>].self, forKey: CodingKeys.bitmaps)
        self.imageLayers = ImageLayers(backgroundImage: backgroundImage,
                   backgroundColor: backgroundColor,
                   rasterLayer: rasterLayer,
                   maskLayer: maskLayer,
                   bitmaps: Set(bitmaps.map { $0.bitmap })
        )
    }
    
    init(imageLayers: ImageLayers<T>) {
        self.imageLayers = imageLayers
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.imageLayers.rasterLayer, forKey: CodingKeys.rasterLayer)
        try container.encode(self.imageLayers.maskLayer, forKey: CodingKeys.maskLayer)
        try container.encode(self.imageLayers.backgroundImage, forKey: CodingKeys.backgroundImage)
        try container.encode(self.imageLayers.backgroundColor, forKey: CodingKeys.backgroundColor)
        try container.encode(self.imageLayers.bitmaps.map { BitmapSerializableWrapper(bitmap: $0) }, forKey: CodingKeys.bitmaps)
    }
}

extension ImageLayers where Reference: Codable {
    
    public func encode() throws -> Data {
        let serializable = ImageLayersSerializableWrapper(imageLayers: self)
        return try JSONEncoder().encode(serializable)
    }
    
    public static func decodingData(data: Data) throws -> ImageLayers<Reference> {
        let decoded = try JSONDecoder().decode(ImageLayersSerializableWrapper<Reference>.self, from: data)
        return decoded.imageLayers
    }
    
    /// Encodes and saves to file
    public func saveToFile(url: URL) throws {
        let data = try self.encode()
        try data.write(to: url)
    }
    
    /// Load from file
    public static func load(url: URL) throws -> ImageLayers<Reference> {
        let data = try! Data(contentsOf: url)
        return try! self.decodingData(data: data)
    }
}

extension KeyedDecodingContainer {
    
    func decodeImageByData(forKey key: KeyedDecodingContainer<K>.Key) throws -> NSImage {
        let data = try self.decode(Data.self, forKey: key)
        guard let image = NSImage(data: data) else {
            throw ImageDecodingError()
        }
        return image
    }
    
    func decodeColor(forKey key: KeyedDecodingContainer<K>.Key) throws -> NSColor {
        let rgba = try self.decode([CGFloat].self, forKey: key)
        guard rgba.count == 4 else {
            throw ImageDecodingError()
        }
        return NSColor(red: rgba[0], green: rgba[1], blue: rgba[2], alpha: rgba[3])
    }
}

extension KeyedEncodingContainer {
    
    mutating func encode(_ value: NSImage, forKey key: KeyedEncodingContainer<K>.Key) throws {
        let data = try value.pngData()
        try self.encode(data, forKey: key)
    }
    
    mutating func encode(_ value: NSColor, forKey key: KeyedEncodingContainer<K>.Key) throws {
        let rgba = [value.redComponent, value.greenComponent, value.blueComponent, value.alphaComponent]
        try self.encode(rgba, forKey: key)
    }
}
