//
//  WindowController.swift
//  Deeva
//
//  Created by Andrew Walker on 2017/01/26.
//  Copyright © 2017 Andrew Walker. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        if let window = window, let screen = window.screen {
            let screenRect = screen.visibleFrame
            window.setFrame(NSRect(x: 0, y: 0, width: screenRect.width, height:screenRect.height), display: true)
            window.titleVisibility = .hidden

        }
    }

}
