//
//  NSOutlet.swift
//  Deeva
//
//  Created by Andrew Walker on 2017/01/27.
//  Copyright © 2017 Andrew Walker. All rights reserved.
//

import Cocoa


extension NSImage {
    class func swatchWithColor(color: NSColor, size: NSSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        color.drawSwatch(in: NSMakeRect(0, 0, size.width, size.height))
        image.unlockFocus()
        return image
    }
}

func createButton(title:String, x:CGFloat, y:CGFloat, w:CGFloat, h:CGFloat) -> NSButton{
    let myButtonRect = CGRect(x:x, y:y, width:w, height:h)
    let myButton = NSButton(frame:myButtonRect)
    myButton.title = title
    myButton.bezelStyle = NSRoundedBezelStyle
    return myButton
}

func createStyledButton(title:String, x:CGFloat, y:CGFloat, w:CGFloat, h:CGFloat, bw:CGFloat, bc:CGColor, bg:CGColor) -> NSButton {
    let myButton = createButton(title:title, x:x, y:y, w:w, h:h)
    myButton.wantsLayer = true
    let layer = CALayer()
    layer.backgroundColor = CGColor(red: 59.0/255, green: 52.0/255.0, blue: 152.0/255.0, alpha: 1.0)
    layer.borderWidth = bw
    layer.borderColor = bc
    myButton.layer = layer
    myButton.title = title
    return myButton
}

func createLabel(title:String, x:CGFloat, y:CGFloat, w:CGFloat, h:CGFloat) -> NSTextField{
    let myDateRect = CGRect(x:x, y:y, width:w, height:h)
    let myDateLabel = NSTextField(frame: myDateRect)
    myDateLabel.stringValue = title
    myDateLabel.isEditable = false
    myDateLabel.alignment = NSTextAlignment.center
    return myDateLabel
}

func createField(placeholder:String, x:CGFloat, y:CGFloat, w:CGFloat, h:CGFloat) -> NSTextField {
    let myDateRect = CGRect(x:x, y:y, width:w, height:h)
    let myDateLabel = NSTextField(frame: myDateRect)
    myDateLabel.placeholderString = placeholder
    return myDateLabel
}

func createView(x:CGFloat, y:CGFloat, w:CGFloat, h:CGFloat, color:CGColor) -> NSView {
    let viewRect = CGRect(x:x, y:y, width:w, height:h)
    let view = NSView(frame: viewRect)
    view.wantsLayer = true
    view.layer?.backgroundColor = color
    return view
}

func createDatePicker(x:CGFloat, y:CGFloat, w:CGFloat, h:CGFloat) -> NSDatePicker {
    let field = NSDatePicker()
    field.frame = NSRect(x: x, y: y, width: w, height: h)
    field.wantsLayer = true
    field.isBordered = false
    field.layer?.backgroundColor = NSColor.white.cgColor
    field.dateValue = NSDate() as Date
    field.datePickerStyle = .textFieldDatePickerStyle
    field.datePickerElements = .init(arrayLiteral: .yearMonthDayDatePickerElementFlag, .hourMinuteDatePickerElementFlag)
    return field
}

func createBlurView(x:CGFloat, y:CGFloat, w:CGFloat, h:CGFloat) -> NSView{
    let newEventBackground = NSView(frame: NSRect(x: 0, y: 0, width: w, height: h))
    newEventBackground.wantsLayer = true
    newEventBackground.layerUsesCoreImageFilters = true
    newEventBackground.layer?.backgroundColor = NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5).cgColor
    let blurFilter = CIFilter(name: "CIGaussianBlur")
    blurFilter?.setDefaults()
    blurFilter?.setValue(2.5, forKey: kCIInputRadiusKey)
    newEventBackground.layer?.backgroundFilters?.append(blurFilter!)
    return newEventBackground
}
