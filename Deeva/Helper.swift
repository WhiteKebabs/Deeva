//
//  Helper.swift
//  Deeva
//
//  Created by Andrew Walker on 2017/01/28.
//  Copyright © 2017 Andrew Walker. All rights reserved.
//

import Foundation
import Cocoa

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}

func getDayOfWeek(today:String)->String {
    
    let formatter  = DateFormatter()
    formatter.dateFormat = "MMM dd yyyy"
    let todayDate = formatter.date(from: today)!
    let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
    let myComponents = myCalendar.components(.weekday, from: todayDate)
    let weekDay = myComponents.weekday
    
    let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    
    return days[weekDay! - 1]
}

func milliToDate(time:Int) -> String{
    let date = NSDate(timeIntervalSince1970: TimeInterval(time))
    let dayTimePeriodFormatter = DateFormatter()
    dayTimePeriodFormatter.dateFormat = "MMM dd YYYY"
    let dateString = dayTimePeriodFormatter.string(from: date as Date)
    return dateString
}

extension NSColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

func calculateFont(toFit textField: NSTextField, withString string: NSString, minSize min: Int, maxSize max: Int) -> NSFont {
    for i in min...max {
        var attr: [String: Any] = [:] as Dictionary
        attr[NSFontSizeAttribute] = NSFont(name: textField.font!.fontName, size: CGFloat(i))!
        let strSize = string.size(withAttributes: [NSFontAttributeName: NSFont.systemFont(ofSize: CGFloat(i))])
        let linesNumber = Int(textField.bounds.height/strSize.height)
        if strSize.width/CGFloat(linesNumber) > textField.bounds.width {
            return (i == min ? NSFont(name: "\(textField.font!.fontName)", size: CGFloat(min)) : NSFont(name: "\(textField.font!.fontName)", size: CGFloat(i-1)))!
        }
    }
    return NSFont(name: "\(textField.font!.fontName)", size: CGFloat(max))!
}
