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

class LineWidthSelectionViewController: NSViewController {
    
    private var selectionCallback: ((Int)->())? = nil
    
    static func showInPopup(over view: NSView, callback: @escaping (Int)->()) {
        let popover = NSPopover()
        let controller = LineWidthSelectionViewController()
        controller.selectionCallback = callback
        popover.contentViewController = controller
        popover.show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
    }
    
    override func loadView() {
        self.view = NSView()
    }
    
    override func viewDidLoad() {
        let views = (1...10).map { (x: Int) -> ClosureButton in
            let width = x * x
            let button = ClosureButton(label: "\(width)") { [weak self] _ in
                self?.didSelect(value: width)
            }
            button.bezelStyle = NSButton.BezelStyle.inline
            return button
        }
        let stack = NSStackView(views: views)
        stack.orientation = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 1
        self.view.addSubview(stack)
        constrain(self.view, stack) { parent, stack in
            stack.edges == parent.edges.inseted(by: 5)
        }
    }
    
    @objc func didSelect(value: Int) {
        self.selectionCallback?(value)
        self.view.window?.close()
    }
}
