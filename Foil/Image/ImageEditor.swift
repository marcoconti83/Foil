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

public enum ToolType {
    case line
    case selection
    case bitmap(NSImage)
}

/// Adds user interaction to image layers
public class ImageEditor {
    
    public let layers: ImageLayers
    
    private(set) var tool: Tool
    
    weak var delegate: ImageEditorDelegate? = nil
    
    public var toolType: ToolType {
        didSet {
            self.setTool(self.toolType)
            self.delegate?.didChangeTool(self.toolType)
        }
    }
    
    public var toolSettings: ToolSettings = ToolSettings() {
        didSet {
            self.tool.settings = self.toolSettings
        }
    }
    
    public var size: NSSize {
        return self.layers.backgroundImage.size
    }
    
    public convenience init(emptyImageOfSize size: NSSize) {
        let backgroundImage = NSImage(size: size)
        self.init(backgroundImage: backgroundImage)
    }
    
    public init(backgroundImage: NSImage) {
        self.layers = ImageLayers(backgroundImage: backgroundImage)
        self.toolSettings.lineWidth = Swift.max(2, backgroundImage.size.min / 200)
        let box = WeakBox<ImageEditor>()
        self.toolType = .line
        self.tool = SelectionTool(
            layers: self.layers,
            settings: self.toolSettings,
            toolSelection: { type in
                box.value?.toolType = type
            }
        )
        box.value = self
        self.layers.redrawDelegate = { [weak self] in
            self?.delegate?.didRedrawImage()
        }
    }
    
    private func setTool(_ tool: ToolType) {
        let toolSelection: (ToolType) -> () = { [weak self] type in
            self?.toolType = type
        }
        switch tool {
        case .line:
            self.tool = LineTool(
                layers: self.layers,
                settings: self.toolSettings,
                toolSelection: toolSelection
            )
        case .selection:
            self.tool = SelectionTool(
                layers: self.layers,
                settings: self.toolSettings,
                toolSelection: toolSelection
            )
        case .bitmap(let image):
            self.tool = BitmapTool(
                layers: self.layers,
                settings: self.toolSettings,
                image: image,
                toolSelection: toolSelection
            )
        }
    }
}


public protocol ImageEditorDelegate: class {
    
    func didRedrawImage()
    func didChangeTool(_ tool: ToolType)
}
