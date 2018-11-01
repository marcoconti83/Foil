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

open class EditorView<Reference: Hashable>: NSView {
    
    public var imageEditView: ImageEditView<Reference>
    
    // Scroll view
    private var scroll: ZoomableScrollView!
    
    var settings: ImageEditorSettings<Reference>
    private var frameChangedNotificationsToken: Any!
    
    public init(settings: ImageEditorSettings<Reference>, layers: ImageLayers<Reference>? = nil) {
        self.settings = settings
        if let layers = layers {
            self.imageEditView = ImageEditView(layers: layers)
        } else {
            let size = settings.size ?? settings.backgroundImage?.size ?? NSSize(width: 300, height: 300)
            self.imageEditView = ImageEditView(frame: size.toRect)
        }
        super.init(frame: NSRect.zero)
        
        self.populateView()
        self.postsFrameChangedNotifications = true
        self.frameChangedNotificationsToken =
            NotificationCenter.default.addObserver(forName: NSView.frameDidChangeNotification,
                                                   object: self,
                                                   queue: nil)
        { [weak self] _ in
            self?.scroll.centerAndZoom()
        }
        self.scroll.centerAndZoom()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self.frameChangedNotificationsToken)
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func populateView() {
        self.scroll = ZoomableScrollView(frame: NSRect.zero)
        self.imageEditView.scrollDelegate = self.scroll
        if let background = self.settings.backgroundImage {
            self.imageEditView.setBackground(background)
        }
        self.scroll.documentView = self.imageEditView
        
        let buttons = [
            ClosureButton(
                image: NSImage(name: "cursor.png", fromClassBundle: EditorView.self)!,
                toolTip: "Select") { [weak self] _ in
                    self?.imageEditView.tool = .selection
            },
            ClosureButton(
                image: NSImage(name: "pencil.png", fromClassBundle: EditorView.self)!,
                toolTip: "Draw lines") { [weak self] _ in
                    self?.imageEditView.tool = .line
            },
            ClosureButton(
                image: NSImage(name: "paintbrush.png", fromClassBundle: EditorView.self)!,
                toolTip: "Brush") { [weak self] _ in
                    self?.imageEditView.tool = .brush
            },
            ClosureButton(
                image: NSImage(name: "pill_delete.png", fromClassBundle: EditorView.self)!,
                toolTip: "Eraser") { [weak self] _ in
                    self?.imageEditView.tool = .eraser
            },
            ClosureButton(
                image: NSImage(name: "shading.png", fromClassBundle: EditorView.self)!,
                toolTip: "Mask") { [weak self] _ in
                    self?.imageEditView.tool = .mask
            },
            self.settings.canAddBitmap ?
            ClosureButton(
                image: NSImage(name: "image_add.png", fromClassBundle: EditorView.self)!,
                toolTip: "Add bitmap") { [weak self] in
                    self?.selectBitmap($0)
            } : nil,
            NSBox.horizontalLine(),
            ClosureButton(
                image: NSImage(name: "color_wheel.png", fromClassBundle: EditorView.self)!,
                toolTip: "Change color"
                ) { [weak self] in
                    self?.selectColor($0)
            },
            ClosureButton(
                image: NSImage(name: "line_size.png", fromClassBundle: EditorView.self)!,
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
        
        self.addSubview(self.scroll)
        self.addSubview(toolbar)
        
        constrain(self, self.scroll, toolbar) { parent, scroll, toolbar in
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
    
    public func centerAndZoom() {
        self.scroll.centerAndZoom()
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
public struct BitmapDefinition<Reference: Hashable> {
    
    public let reference: Reference?
    public let image: NSImage
    public let scale: CGFloat
    public let label: String?
    
    public init(
        image: NSImage,
        scale: CGFloat,
        label: String? = nil,
        reference: Reference? = nil) {
        self.image = image
        self.reference = reference
        self.scale = scale
        self.label = label
    }
}
