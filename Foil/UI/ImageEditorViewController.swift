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

open class ImageEditorViewController: NSViewController {

    public var imageEditView: ImageEditView!
    private var scroll: ZoomableScrollView!
    var settings: ImageEditorSettings
    
    public init(settings: ImageEditorSettings) {
        self.settings = settings
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    override open func loadView() {
        self.view = NSView()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.scroll = ZoomableScrollView(frame: NSRect.zero)
        let size = self.settings.size ?? self.settings.backgroundImage?.size ?? NSSize(width: 300, height: 300)
        self.imageEditView = ImageEditView(frame: size.toRect)
        self.imageEditView.scrollDelegate = self.scroll
        if let background = self.settings.backgroundImage {
            self.imageEditView.setBackground(background)
        }
        self.scroll.documentView = self.imageEditView
        
        let buttons = [
            ClosureButton(
                image: NSImage(name: "cursor.png", fromClassBundle: ImageEditorViewController.self)!,
                toolTip: "Select") { [weak self] _ in
                    self?.imageEditView!.tool = .selection
            },
            ClosureButton(
                image: NSImage(name: "pencil.png", fromClassBundle: ImageEditorViewController.self)!,
                toolTip: "Draw lines") { [weak self] _ in
                    self?.imageEditView!.tool = .line
            },
            ClosureButton(
                image: NSImage(name: "paintbrush.png", fromClassBundle: ImageEditorViewController.self)!,
                toolTip: "Brush") { [weak self] _ in
                    self?.imageEditView!.tool = .brush
            },
            ClosureButton(
                image: NSImage(name: "pill_delete.png", fromClassBundle: ImageEditorViewController.self)!,
                toolTip: "Eraser") { [weak self] _ in
                    self?.imageEditView!.tool = .eraser
            },
            ClosureButton(
                image: NSImage(name: "shading.png", fromClassBundle: ImageEditorViewController.self)!,
                toolTip: "Mask") { [weak self] _ in
                    self?.imageEditView!.tool = .mask
            },
            self.settings.canAddBitmap ?
            ClosureButton(
                image: NSImage(name: "image_add.png", fromClassBundle: ImageEditorViewController.self)!,
                toolTip: "Add bitmap") { [weak self] in
                    self?.selectBitmap($0)
            } : nil,
            NSBox.horizontalLine(),
            ClosureButton(
                image: NSImage(name: "color_wheel.png", fromClassBundle: ImageEditorViewController.self)!,
                toolTip: "Change color"
                ) { [weak self] in
                    self?.selectColor($0)
            },
            ClosureButton(
                image: NSImage(name: "line_size.png", fromClassBundle: ImageEditorViewController.self)!,
                toolTip: "Change line width"
                ) { [weak self] in
                    self?.selectLineSize($0)
            },
            NSBox.horizontalLine()
            ].compactMap { $0 }
        
        let customButton = settings.toolbarItems.map { item in
            return ClosureButton(image: item.icon, toolTip: item.tooltip) { [weak self] _ in
                guard let `self` = self else { return }
                item.action(self.imageEditView)
            }
        }
        let toolbar = NSStackView(views: buttons + customButton)
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
    
    open override func viewDidAppear() {
        self.scroll.centerAndZoom()
    }
    
    private func selectBitmap(_ sender: Any) {
        guard let view = sender as? NSView else { return }
        BitmapSelectionViewController(
            images: settings.possibleBitmaps,
            allowImagesFromFile: settings.allowImagesFromFile,
            customBitmapPicker: settings.customBitmapPicker
        )
            .showInPopup(over: view) { img in
                self.imageEditView.tool = .bitmap(img)
        }
    }
    
    private func selectLineSize(_ sender: Any) {
        guard let view = sender as? NSView else { return }
        LineWidthSelectionViewController().showInPopup(over: view) { [weak self] value in
            self?.imageEditView.toolSettings.lineWidth = CGFloat(value)
        }
    }
    
    private func selectColor(_ sender: Any) {
        guard let view = sender as? NSView else { return }
        ColorSelectionViewController().showInPopup(over: view) { [weak self] value in
            self?.imageEditView.toolSettings.color = value
        }
    }
    
    public var image: NSImage {
        return self.imageEditView.image
    }
}

extension ClosureButton {
    
    convenience init(image: NSImage, toolTip: String, closure: @escaping (Any)->()) {
        self.init(image: image, closure: closure)
        self.toolTip = toolTip
        self.bezelStyle = BezelStyle.shadowlessSquare
    }
}

/// A bitmap that is not placed on the image yet
public struct BitmapDefinition {
    
    let reference: AnyHashable?
    let image: NSImage
    let scale: CGFloat
    
    public init(image: NSImage, scale: CGFloat, reference: AnyHashable? = nil) {
        self.image = image
        self.reference = reference
        self.scale = scale
    }
}
