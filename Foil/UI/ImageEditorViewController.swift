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
    

import Cocoa
import Cartography
import ClosureControls

public class ImageEditorViewController: NSViewController {

    private var imageEditView: ImageEditView!
    private var scroll: ZoomableScrollView!
    
    override public func loadView() {
        self.view = NSView()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.scroll = ZoomableScrollView(frame: NSRect.zero)
        self.imageEditView = ImageEditView(frame: NSRect.zero)
        self.imageEditView.scrollDelegate = self.scroll
        self.scroll.documentView = self.imageEditView
        
        let buttons = [
            ClosureButton(
                image: NSImage(name: "cursor.png")!,
                toolTip: "Select") { [weak self] _ in
                    self?.imageEditView!.tool = .selection
            },
            ClosureButton(
                image: NSImage(name: "pencil.png")!,
                toolTip: "Draw lines") { [weak self] _ in
                    self?.imageEditView!.tool = .line
            },
            ClosureButton(
                image: NSImage(name: "image_add.png")!,
                toolTip: "Add bitmap") { [weak self] _ in
                    self?.selectBitmap()
            },
            NSBox.horizontalLine(),
            ClosureButton(
                image: NSImage(name: "color_wheel.png")!,
                toolTip: "Change color"
                ) { [weak self] in
                    self?.selectColor($0)
            },
            ClosureButton(
                image: NSImage(name: "line_size.png")!,
                toolTip: "Change line width"
                ) { [weak self] in
                    self?.selectLineSize($0)
            }
        ]
        let toolbar = NSStackView(views: buttons)
        toolbar.orientation = .vertical
        toolbar.distribution = .gravityAreas
        toolbar.spacing = 1
        
        self.view.addSubview(self.scroll)
        self.view.addSubview(toolbar)
        
        constrain(self.view, self.scroll, toolbar) { parent, scroll, toolbar in
            toolbar.width == 30
            toolbar.top == parent.top
            toolbar.left == parent.left
            toolbar.right == scroll.left
            toolbar.bottom == parent.bottom
            
            scroll.top == parent.top
            scroll.bottom == parent.bottom
            scroll.right == parent.right
            
            scroll.height >= 200
            scroll.width >= 200
        }
    }
    
    public override func viewDidAppear() {
        self.scroll.centerAndZoom()
    }
    
    private func selectBitmap() {
        self.imageEditView.tool = .bitmap(NSImage(name: "color_wheel.png")!)
    }
    
    private func selectLineSize(_ sender: Any) {
        guard let view = sender as? NSView else { return }
        LineWidthSelectionViewController.showInPopup(over: view) { [weak self] value in
            self?.imageEditView.toolSettings.lineWidth = CGFloat(value)
        }
    }
    
    private func selectColor(_ sender: Any) {
        guard let view = sender as? NSView else { return }
        ColorSelectionViewController.showInPopup(over: view) { [weak self] value in
            self?.imageEditView.toolSettings.color = value
        }
    }
}

extension ClosureButton {
    
    convenience init(image: NSImage, toolTip: String, closure: @escaping (Any)->()) {
        self.init(image: image, closure: closure)
        self.toolTip = toolTip
        self.bezelStyle = BezelStyle.shadowlessSquare
    }
}

