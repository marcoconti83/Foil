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

public protocol Tool {
    
    func didPressKey(key: Keycode)
    func didMouseDown(_ point: NSPoint, shiftKeyPressed: Bool)
    func didMouseUp(_ point: NSPoint, shiftKeyPressed: Bool)
    func didDragMouse(_ point: NSPoint)
    func didMoveMouse(_ point: NSPoint)
    
    var settings: ToolSettings { get set }
}

class ToolMixin {
    
    let layers: ImageLayers
    let toolSelection: (ToolType)->Void
    var settings: ToolSettings {
        didSet {
            self.updateSettings()
        }
    }
    
    init(layers: ImageLayers, settings: ToolSettings, toolSelection: @escaping (ToolType)->Void) {
        self.layers = layers
        self.settings = settings
        self.toolSelection = toolSelection
    }
    
    func updateSettings() {
        
    }
    
    func didPressKey(key: Keycode) {}
    func didMouseDown(_ point: NSPoint, shiftKeyPressed: Bool) {}
    func didMouseUp(_ point: NSPoint, shiftKeyPressed: Bool) {}
    func didDragMouse(_ point: NSPoint) {}
    func didMoveMouse(_ point: NSPoint) {}
}

public struct ToolSettings {
    public var color: NSColor
    public var lineWidth: CGFloat
    
    public init(color: NSColor = .black, lineWidth: CGFloat = 2) {
        self.color = color
        self.lineWidth = lineWidth
    }
}
