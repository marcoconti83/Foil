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
import Cartography
import ClosureControls

class BitmapSelectionViewController: PopupChoiceViewController<NSImage> {
    
    let images: [NSImage]
    let allowImagesFromFile: Bool
    
    init(images: [NSImage], allowImagesFromFile: Bool) {
        self.images = images
        self.allowImagesFromFile = allowImagesFromFile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        let topView = NSView()
        let bottomView = NSView()
        
        self.view.addSubview(topView)
        self.view.addSubview(bottomView)
        constrain(topView, bottomView, self.view) { top, bottom, parent in
            top.top == parent.top
            top.left == parent.left
            top.right == parent.right
            top.bottom == bottom.top
            bottom.left == parent.left
            bottom.right == parent.right
            bottom.bottom == parent.bottom
        }
        
        if !self.images.isEmpty {
            let images = self.images.map { img in
                ClosureButton(image: img.resized(to: NSSize(width: 25, height: 25))!) { [weak self] _ in
                    self?.didSelect(value: img)
                }
            }.group(size: 5)
            let stack = NSStackView.grid(views: images)
            topView.addSubview(stack)
            constrain(stack, topView) { stack, top in
                stack.edges == top.edges
            }
        }
        
        if self.allowImagesFromFile {
            let button = ClosureButton(label: "Pick from file...") { [weak self] _ in
                let panel = NSOpenPanel()
                panel.canChooseDirectories = false
                panel.canChooseFiles = true
                panel.allowsMultipleSelection = false
                panel.allowedFileTypes = ["png", "jpg", "jpeg"]
                panel.beginSheetModal(for: NSApp.keyWindow!) { response in
                    if response == .OK,
                        let image = panel.url.flatMap({ NSImage(contentsOf: $0)})
                    {
                        self?.didSelect(value: image)
                    }
                }
            }
            bottomView.addSubview(button)
            constrain(button, bottomView) { button, bottom in
                button.edges == bottom.edges
            }
        }
    }
}


extension NSImage {
    func resized(to newSize: NSSize) -> NSImage? {
        if let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
            ) {
            bitmapRep.size = newSize
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
            draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), from: .zero, operation: .copy, fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()
            
            let resizedImage = NSImage(size: newSize)
            resizedImage.addRepresentation(bitmapRep)
            return resizedImage
        }
        
        return nil
    }
}
