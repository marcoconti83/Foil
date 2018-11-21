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
    let customBitmapPicker: ((BitmapPicker)->())?
    
    init(images: [NSImage],
         allowImagesFromFile: Bool,
         customBitmapPicker: ((BitmapPicker)->())?) {
        self.images = images
        self.allowImagesFromFile = allowImagesFromFile
        self.customBitmapPicker = customBitmapPicker
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        let topView = NSView()
        let bottomView = NSStackView()
        bottomView.orientation = .vertical
        
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
                ClosureButton(image: img.resized(size: NSSize(width: 25, height: 25))!) { [weak self] _ in
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
                self?.view.window?.close()
                let panel = NSOpenPanel()
                panel.canChooseDirectories = false
                panel.canChooseFiles = true
                panel.allowsMultipleSelection = false
                panel.allowedFileTypes = ["png", "jpg", "jpeg"]
                panel.beginSheetModal(for: NSApp.keyWindow!) { response in
                    guard response == .OK,
                        let image = panel.url.flatMap({ NSImage(contentsOf: $0)})
                        else {
                            return
                    }
                    self?.didSelect(value: image)
                }
            }
            bottomView.addArrangedSubview(button)
        }
        
        if let customBitmapPicker = self.customBitmapPicker {
            let button = ClosureButton(label: "Pick bitmap...") { [weak self] _ in
                self?.view.window?.close()
                customBitmapPicker() { image in
                    if let image = image {
                        self?.didSelect(value: image)
                    }
                }
            }
            bottomView.addArrangedSubview(button)
        }
    }
}
