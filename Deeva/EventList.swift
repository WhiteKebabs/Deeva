//
//  EventList.swift
//  Deeva
//
//  Created by Andrew Walker on 2017/01/31.
//  Copyright © 2017 Andrew Walker. All rights reserved.
//

import Foundation
import CoreData

class EventList {
    
    private var eventList =  [String: [String:[Event]]]()
    private var repeatedList = [String:[Event]]()
    
    func initialise(data:[NSManagedObject]) {
        for event in data {
            
            // Create event object from NSManagedObject
            let _ = addEvent(
                name:event.value(forKey: "name") as! String,
                startDate:event.value(forKey: "startDate") as! Date,
                endDate: event.value(forKey: "endDate") as! Date,
                flexible: event.value(forKey: "flexible") as! Bool,
                repeats: event.value(forKey: "repeats") as! String,
                location: event.value(forKey: "location") as! String,
                extraInfo: event.value(forKey: "extraInfo") as! String
            )
        }
    }
    
    func getRepeated(day:String) -> [Event]? {
        if let dayList = repeatedList[day] {
            return dayList
        }
        return nil
    }
    
    func getDate(date:String) -> [String:[Event]]?{
        if let dayList = eventList[date] {
            return dayList
        }
        return nil
    }
    
    func addEvent(name:String, startDate:Date, endDate:Date, flexible:Bool, repeats:String, location:String, extraInfo:String) -> Bool {
        let newEvent = Event(name:name, startDate:startDate, endDate:endDate, flexible:flexible,
                             repeats:repeats, location:location, extraInfo:extraInfo)
        
        if repeats != "" {
            let days = repeats.components(separatedBy: " ")
            for i in 1...days.count-1 {
                var dList = repeatedList[days[i]]
                if dList == nil {
                    dList = [Event]()
                }
                dList?.append(newEvent)
                repeatedList[days[i]] = dList
            }
            return true
        }
        
        // Find destination in data structure
        var dayList = eventList[newEvent.getStartTime(format: "MMM/dd/yyyy")]
        if dayList == nil {
            dayList = [String:[Event]]()
        }
        
        var hourList = dayList?[newEvent.getStartTime(format: "HH")]
        if hourList == nil {
            hourList = [Event]()
        }
        
        // Make sure there is no clash
        if (hourList != nil) {
            for event in hourList! {
                if newEvent.clashesWith(newEvent: event){
                    return false
                }
            }
        }

        
        // Add to data structure
        hourList?.append(newEvent)
        // ---------- SORT HERE -----------
        dayList?[newEvent.getStartTime(format: "HH")] = hourList
        eventList[newEvent.getStartTime(format: "MMM/dd/yyyy")] = dayList
        
        return true
    }
    
    func deleteEvent(startDate:Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM/dd/yyyy"
        let date = formatter.string(from: startDate)
        formatter.dateFormat = "HH"
        let hour = formatter.string(from: startDate)
        formatter.dateFormat = "MMM/dd/yyyy HH:mm"
        let fullTime = formatter.string(from: startDate)
        
        // Find the event
        var dayList = eventList[date]
        var hourList = dayList?[hour]
        
        for i in 0...hourList!.count - 1 {
            if hourList?[i].getStartTime(format: "MMM/dd/yyyy HH:mm") == fullTime {
                hourList?.remove(at: i)
                return true
            }
        }
        
        return false
    }
    
    func printEventList() {
        for (key, value) in eventList {
            print("kind: \(key)")
            for (key2, value2) in value {
                print("kind: \(key2)")
                for event in value2 {
                    print(event.getName())
                }
            }
        }
    }
    
}

