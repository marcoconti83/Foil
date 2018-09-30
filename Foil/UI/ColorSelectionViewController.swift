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

class ColorSelectionViewController: PopupChoiceViewController<NSColor> {
        
    static let colors: [NSColor] = [
        NSColor(red: 0.902, green: 0.098, blue: 0.294, alpha: 1), // Red
        NSColor(red: 0.235, green: 0.706, blue: 0.294, alpha: 1), // Green
        NSColor(red: 1.000, green: 0.882, blue: 0.098, alpha: 1), // Yellow
        NSColor(red: 0.000, green: 0.510, blue: 0.784, alpha: 1), // Blue
        NSColor(red: 0.961, green: 0.510, blue: 0.188, alpha: 1), // Orange
        NSColor(red: 0.569, green: 0.118, blue: 0.706, alpha: 1), // Purple
        NSColor(red: 0.275, green: 0.941, blue: 0.941, alpha: 1), // Cyan
        NSColor(red: 0.941, green: 0.196, blue: 0.902, alpha: 1), // Magenta
        NSColor(red: 0.824, green: 0.961, blue: 0.235, alpha: 1), // Lime
        NSColor(red: 0.980, green: 0.745, blue: 0.745, alpha: 1), // Pink
        NSColor(red: 0.000, green: 0.502, blue: 0.502, alpha: 1), // Teal
        NSColor(red: 0.902, green: 0.745, blue: 1.000, alpha: 1), // Lavender
        NSColor(red: 0.667, green: 0.431, blue: 0.157, alpha: 1), // Brown
        NSColor(red: 1.000, green: 0.980, blue: 0.784, alpha: 1), // Beige
        NSColor(red: 0.502, green: 0.000, blue: 0.000, alpha: 1), // Maroon
        NSColor(red: 0.667, green: 1.000, blue: 0.765, alpha: 1), // Mint
        NSColor(red: 0.502, green: 0.502, blue: 0.000, alpha: 1), // Olive
        NSColor(red: 1.000, green: 0.843, blue: 0.706, alpha: 1), // Apricot
        NSColor(red: 0.000, green: 0.000, blue: 0.502, alpha: 1), // Navy
        NSColor(red: 0.502, green: 0.502, blue: 0.502, alpha: 1), // Grey
        NSColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1), // White
        NSColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1), // Black
    ]
    
    override func viewDidLoad() {
        let stacks = ColorSelectionViewController
            .colors.group(size: 5).map { (colors: [NSColor]) -> NSStackView in
            let views = colors.map { $0.sampleButton(self) }
            let stack = NSStackView(views: views)
            stack.orientation = .horizontal
            stack.distribution = .fillEqually
            stack.spacing = 1
            return stack
        }
        let stack = NSStackView(views: stacks)
        stack.orientation = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 1
        self.view.addSubview(stack)
        constrain(self.view, stack) { parent, stack in
            stack.edges == parent.edges.inseted(by: 5)
        }
    }
}


extension NSColor {
    
    fileprivate func sampleButton(_ controller: ColorSelectionViewController) -> ClosureButton {
        let button = ClosureButton(image: self.sampleImage) { [weak controller] _ in
            controller?.didSelect(value: self)
        }
        return button
    }
    
    private var sampleImage: NSImage {
        let rect = NSRect(x: 0, y: 0, width: 25, height: 25)
        let image = NSImage(size: rect.size)
        image.lockingFocus {
            restoringGraphicState {
                self.setFill()
                rect.fill()
            }
        }
        return image
    }
}

