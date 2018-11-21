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

public protocol AbstractBitmapContainer: AnyObject {
    
    associatedtype Reference: Hashable
    
    /// Place new bitmaps, distributing them in a way that they don't overlap each other and
    /// tries a best-effort into having them fit the image, but they might overflow the image
    func placeNewBitmaps(_ bitmapDefinitions: [BitmapDefinition<Reference>])
    
    /// Bitmaps in the collection
    var bitmaps: Set<Bitmap<Reference>> { get set }
    
    /// Select bitmaps by reference
    func selectBitmapsByReference(_ references: Set<Reference>, extendSelection: Bool)
    
    /// Add an observer that will be notified when bitmaps are selected/deselected
    /// It will return an observer token, when the token is released the observer is removed
    func addBitmapSelectionObserver(block: @escaping (Set<Bitmap<Reference>>) -> ()) -> Any
}

extension AbstractBitmapContainer {
    
    /// Remove bitmaps by reference
    public func removeBitmapsByReference(_ references: Set<Reference>) {
        let filtered = self.bitmaps.filter {
            $0.reference != nil && !references.contains($0.reference!)
        }
        self.bitmaps = filtered
    }
}

/// Type erasure on BitmapContainer to bypass PAT restrictions. This is horrible :(
public class BitmapContainer<Reference: Hashable>: AbstractBitmapContainer {
    
    private let _placeNewBitmaps: ([BitmapDefinition<Reference>])->()
    private let _getBitmaps: ()->Set<Bitmap<Reference>>
    private let _setBitmaps: (Set<Bitmap<Reference>>)->()
    private let _selectBitmapsByReference: (Set<Reference>, Bool)->()
    private let _addBitmapSelectionObserver: (@escaping (Set<Bitmap<Reference>>) -> ())->Any
    
    init<T: AbstractBitmapContainer>(_ container: T) where T.Reference == Reference {
        self._placeNewBitmaps = container.placeNewBitmaps
        self._getBitmaps = { container.bitmaps }
        self._setBitmaps = { container.bitmaps = $0 }
        self._selectBitmapsByReference = container.selectBitmapsByReference
        self._addBitmapSelectionObserver = container.addBitmapSelectionObserver
    }
    
    public func placeNewBitmaps(_ bitmapDefinitions: [BitmapDefinition<Reference>]) {
        self._placeNewBitmaps(bitmapDefinitions)
    }
    
    public var bitmaps: Set<Bitmap<Reference>> {
        get {
            return self._getBitmaps()
        }
        set {
            self._setBitmaps(newValue)
        }
    }
    
    public func selectBitmapsByReference(_ references: Set<Reference>, extendSelection: Bool) {
        self._selectBitmapsByReference(references, extendSelection)
    }
    
    public func addBitmapSelectionObserver(block: @escaping (Set<Bitmap<Reference>>) -> ()) -> Any {
        return self._addBitmapSelectionObserver(block)
    }
    
    
    
}

