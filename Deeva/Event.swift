//
//  Event.swift
//  Deeva
//
//  Created by Andrew Walker on 2017/01/31.
//  Copyright © 2017 Andrew Walker. All rights reserved.
//

import Foundation

class Event {
    
    private var name:String
    private var startDate:Date
    private var endDate:Date
    private var flexible:Bool
    private var repeats:[String]
    private var location:String
    private var extraInfo:String
    private var color:String
    
    init(name:String, startDate:Date, endDate:Date, flexible:Bool, repeats:String, location:String, extraInfo:String, color:String) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.flexible = flexible
        self.repeats = repeats.components(separatedBy: " ")
        self.location = location
        self.extraInfo = extraInfo
        self.color = color
    }
    
    func clashesWith(newEvent:Event) -> Bool {
        if newEvent.startDate.timeIntervalSince1970 < self.endDate.timeIntervalSince1970 &&
            newEvent.startDate.timeIntervalSince1970 > self.startDate.timeIntervalSince1970 {
            return true
        }
        else if newEvent.endDate.timeIntervalSince1970 < self.endDate.timeIntervalSince1970 &&
            newEvent.endDate.timeIntervalSince1970 > self.startDate.timeIntervalSince1970 {
            return true
        }
        return false
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getStartTime(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self.startDate)
    }
    
    func getEndTime(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self.endDate)
    }
    
    func isFlexible() -> Bool {
        return self.flexible
    }
    
    func getLocation() -> String {
        return self.location
    }
    
    func getRepeats() -> [String] {
        return self.repeats
    }
    
    func getExtraInfo() -> String {
        return self.extraInfo
    }
    
    func getColor() -> String {
        return self.color
    }
    
    func equals(event:Event) -> Bool {
        if event.getName() != self.name {
            return false
        }
        if event.getStartTime(format: "MMM dd yyyy HH:mm") != self.getStartTime(format: "MMM dd yyyy HH:mm") {
            return false
        }
        return true
    }
    
}
