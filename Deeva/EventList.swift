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
    
    func initialise(data:[NSManagedObject]) {
        for event in data {
            
            // Create event object from NSManagedObject
            let _ = addEvent(
                name:event.value(forKey: "name") as! String,
                startDate:event.value(forKey: "startDate") as! Date,
                endDate: event.value(forKey: "endDate") as! Date,
                flexible: event.value(forKey: "flexible") as! Bool,
                repeats: event.value(forKey: "repeats") as! [String],
                location: event.value(forKey: "location") as! String,
                extraInfo: event.value(forKey: "extrainfo") as! String
            )
        }
    }
    
    func getDate(date:String) -> [String:[Event]]{
        return eventList[date]!
    }
    
    func addEvent(name:String, startDate:Date, endDate:Date, flexible:Bool, repeats:[String], location:String, extraInfo:String) -> Bool {
        let newEvent = Event(name:name, startDate:startDate, endDate:endDate, flexible:flexible,
                             repeats:repeats, location:location, extraInfo:extraInfo)
        
        // Find destination in data structure
        var dayList = eventList[newEvent.getStartTime(format: "MMM/dd/yyyy")]
        var hourList = dayList?[newEvent.getStartTime(format: "HH")]
        
        // Make sure there is no clash
        for event in hourList! {
            if newEvent.clashesWith(newEvent: event){
                return false
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
    
}
