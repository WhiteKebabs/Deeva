//
//  ViewController.swift
//  Deeva
//
//  Created by Andrew Walker on 2017/01/26.
//  Copyright © 2017 Andrew Walker. All rights reserved.
//

import Cocoa
import CoreData

class ViewController: NSViewController {

    // Dimensions
    var awakeTime = 9
    var width = CGFloat()
    var height = CGFloat()
    
    // Outlets
    var hourContainers: [NSView] = []
    var newEventFields: [AnyObject] = [] // CLEAR DATA AFTER USAGE
    var myDateLabel = NSTextField()
    var newEventWindow = NSView()
    var newEventBackground = NSView()
    
    // Event fields
    var savedEvents = [NSManagedObject]()
    var eventList = EventList()
    var eventButtons: [NSButton] = []
    var currEvent = NSManagedObject()
    var buttonEventMap =  [String: Event]() // CLEAR DATA AFTER USAGE
    var displayedEvent = String()
    
    func changeDate(button: NSButton){
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd yyyy"
        var currentDateTime = Double((formatter.date(from: myDateLabel.stringValue)?.timeIntervalSince1970)!)
        if button.title == "<" { currentDateTime -= 8.64e+4 }
        else { currentDateTime += 8.64e+4 }
        myDateLabel.stringValue = milliToDate(time: Int(currentDateTime))
        reloadData()
    }
    
    func reloadData(){
        
        //eventList.printEventList()
        
        // Remove all event buttons on display
        for button in eventButtons {
            button.removeFromSuperview()
        }
        
        // Convert the current date to a key for retrieving events
        let key = myDateLabel.stringValue.replacingOccurrences(of: " ", with: "/")
        let currDayEvents = eventList.getDate(date: key)
        
        // Find width of button area
        let buttonArea = (width-150)/2
        
        // Loop through all hours in currDayEvent
        for var i in 0...23 {
            
            // Loop through all events occuring in the hour
            let hourList = currDayEvents?[String((i+awakeTime)%24)]
            if hourList == nil { continue }
            for event in hourList! {
                
                // Add necessary number of buttons for event duration
                var start = Int(event.getStartTime(format: "mm"))!
                let end = Int(event.getEndTime(format: "mm"))!
                let endHour = Int(event.getEndTime(format: "HH"))! - 9
                while i <= endHour {
                    
                    let title = event.getName() + "\n" + event.getStartTime(format: "HH:mm") +
                        " - " + event.getEndTime(format: "HH:mm")
                    let x = 75 + buttonArea*CGFloat(Double(start)/Double(60))
                    
                    // If the button to the end of the hour
                    if i < endHour {
                        let w = buttonArea*CGFloat(Double(60-start)/Double(60))
                        let button = createButton(title:title, x:x, y:0, w:w, h:hourContainers[i].frame.height)
                        button.action = #selector(displayExistingEvent)
                        hourContainers[i].addSubview(button)
                        eventButtons.append(button)
                        buttonEventMap[title] = event
                        start = 0
                    }
                        
                    // If the button does not go to the end
                    else {
                        let w = buttonArea*CGFloat(Double(end-start)/Double(60))
                        let button = createButton(title:title, x:x, y:0, w:w, h:hourContainers[i].frame.height)
                        button.action = #selector(displayExistingEvent)
                        hourContainers[i].addSubview(button)
                        eventButtons.append(button)
                        buttonEventMap[title] = event
                    }
                    i += 1
                }
            }
        }
        
        if let repeatedEvents = eventList.getRepeated(day: getDayOfWeek(today: myDateLabel.stringValue)) {
            for event in repeatedEvents {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM dd yyyy"
                let currentDateTime = Double((formatter.date(from: myDateLabel.stringValue)?.timeIntervalSince1970)!)
                let eventStartTime = Double((formatter.date(from: event.getStartTime(format: "MMM dd yyyy"))?.timeIntervalSince1970)!)
                let repeats = event.getRepeats()
                formatter.dateFormat = "MMM/dd/yyyy"
                let eventEndTime = Double((formatter.date(from: repeats[0])?.timeIntervalSince1970)!)
                if currentDateTime >= eventStartTime && currentDateTime <= eventEndTime {
                
                    // Add necessary number of buttons for event duration
                    var start = Int(event.getStartTime(format: "mm"))!
                    let end = Int(event.getEndTime(format: "mm"))!
                    let startHour = Int(event.getStartTime(format: "HH"))!
                    let endHour = Int(event.getEndTime(format: "HH"))!
                
                    var i = startHour
                    //var i = (start+awakeTime)%24
                
                    while i <= endHour {
                    
                        let title = event.getName() + "\n" + event.getStartTime(format: "HH:mm") +
                            " - " + event.getEndTime(format: "HH:mm")
                        let x = 75 + buttonArea*CGFloat(Double(start)/Double(60))
                    
                        // If the button to the end of the hour
                        if i < endHour {
                            let w = buttonArea*CGFloat(Double(60-start)/Double(60))
                            let button = createButton(title:title, x:x, y:0, w:w, h:hourContainers[i].frame.height)
                            button.action = #selector(displayExistingEvent)
                            hourContainers[(i+awakeTime+6)%24].addSubview(button)
                            eventButtons.append(button)
                            buttonEventMap[title] = event
                            start = 0
                        }
                        
                            // If the button does not go to the end
                        else {
                            let w = buttonArea*CGFloat(Double(end-start)/Double(60))
                            let button = createButton(title:title, x:x, y:0, w:w, h:hourContainers[i].frame.height)
                            button.action = #selector(displayExistingEvent)
                            hourContainers[(i+awakeTime+6)%24].addSubview(button)
                            eventButtons.append(button)
                            buttonEventMap[title] = event
                        }
                        i += 1
                    }
                }
                
            }
        }
        
    }
    
    func deleteEvent(){
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        managedContext.delete(currEvent)
        savedEvents.remove(at: savedEvents.index(of: currEvent)!)

        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        closeNewEvent()
        reloadData()
    }
    
    func pressedRepeatDay(button:NSButton){
        if button.layer?.backgroundColor == NSColor.blue.cgColor {
            button.wantsLayer = true
            button.layer?.backgroundColor = NSColor.lightGray.cgColor
        }
        else {
            button.wantsLayer = true
            button.layer?.backgroundColor = NSColor.blue.cgColor
        }
    }
    
    func pressedRepeat(button:NSButton){
        button.wantsLayer = true
        
        if button.layer?.backgroundColor == NSColor.blue.cgColor {
            button.layer?.backgroundColor = NSColor.lightGray.cgColor
        }
        
        else {
            button.layer?.backgroundColor = NSColor.blue.cgColor
            
            let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
            
            newEventWindow.setFrameSize(NSSize(width: 400, height: 550))
            newEventWindow.setFrameOrigin(NSPoint(x:newEventWindow.frame.origin.x, y:newEventWindow.frame.origin.y-80))
            for i in 0...newEventFields.count-1 {
                newEventFields[i].setFrameOrigin(NSPoint(x:newEventFields[i].frame.origin.x, y:newEventFields[i].frame.origin.y+160))
            }
            for i in 0...6 {
                let button = NSButton(frame:NSRect(x:100 + 100*Int(Double(i)/4.0), y:205 - 30*(i%4) , width:100, height:30))
                button.bezelStyle = NSRegularSquareBezelStyle
                button.title = days[i]
                button.action = #selector(pressedRepeatDay)
                newEventFields.append(button)
                newEventWindow.addSubview(button)
            }
            
            let field = createDatePicker(x: 400/7 + 1, y: 400/10 + 40, w: 400*5/7 - 2, h: 35)
            newEventWindow.addSubview(field)
            newEventFields.append(field)
            
        }
    }
    
    func saveNewEvent(){
        
        // Connect to core data
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "Plan", in:managedContext)
        let plan = NSManagedObject(entity: entity!, insertInto: managedContext)

        // Extract NSDatePicker date values
        let newStartDate = (newEventFields[0] as! NSDatePicker).dateValue
        let newEndDate = (newEventFields[1] as! NSDatePicker).dateValue
        
        // Extract repeat days
        var repeatDays = [String]()
        if (newEventFields[6] as! NSButton).layer?.backgroundColor == NSColor.blue.cgColor {
            for i in 7...13 {
                if (newEventFields[i] as! NSButton).layer?.backgroundColor == NSColor.blue.cgColor{
                    repeatDays.append((newEventFields[i] as! NSButton).title)
                }
            }
        }
        var rep = ""
        if repeatDays.count > 0 {
            let endDate = newEventFields[newEventFields.count-1] as! NSDatePicker
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM/dd/yyyy"
            repeatDays.insert(formatter.string(from: endDate.dateValue), at: 0)
            rep = repeatDays.joined(separator: " ")
        }
        
        // Add event to data structure
        _ = eventList.addEvent(name: newEventFields[2].stringValue as String, startDate:newStartDate, endDate:newEndDate,
                           flexible: newEventFields[3].stringValue.toBool()!, repeats: rep,
                           location:newEventFields[4].stringValue, extraInfo:newEventFields[5].stringValue)
        
        // Create NSManagedObject
        plan.setValue((newEventFields[2] as! NSTextField).stringValue, forKey: "name")
        plan.setValue(newStartDate, forKey: "startDate")
        plan.setValue(newEndDate, forKey: "endDate")
        plan.setValue(rep, forKey: "repeats")
        plan.setValue(Int(newEventFields[3].stringValue)!, forKey: "flexible")
        plan.setValue((newEventFields[4] as! NSTextField).stringValue, forKey: "location")
        plan.setValue((newEventFields[5] as! NSTextField).stringValue, forKey: "extraInfo")
        
        // Add to core data
        do {
            try managedContext.save()
            savedEvents.append(plan)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        reloadData()
        closeNewEvent()
    }
    
    func closeNewEvent(){
        newEventWindow.removeFromSuperview()
        newEventBackground.removeFromSuperview()
    }
    
    func openNewEvent(){
        openEventDisplay(function: "new", event:Event(name:"", startDate:NSDate() as Date, endDate:NSDate() as Date, flexible:true, repeats:"", location:"", extraInfo:""))
    }
    
    func displayExistingEvent(button:NSButton){
        openEventDisplay(function: "existing", event:buttonEventMap[button.title]!)
    }
    
    func openEventDisplay(function:String, event:Event){
        
        // Create the window for the fields
        newEventWindow = createView(x: width/2 - 200, y: height/2 - 200, w: 400, h: 400, color:NSColor(netHex:0xecf0f1).cgColor)
        newEventWindow.layer?.cornerRadius = 10
        
        // Create a blurry panel to prevent interactions with buttons in the background
        newEventBackground = createBlurView(x:0, y:0, w:width, h:height)
        self.view.addSubview(newEventBackground)
        
        // Generate Fields
        
        if function == "existing" {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM/dd/yyyy HH:mm:ss"
            
            // Start Date
            let field = createDatePicker(x: 400/7 + 1, y: 400*CGFloat(7.0/9) - CGFloat(33.5*Double(0)), w: 400*5/7 - 4, h: 32)
            field.dateValue = formatter.date(from: event.getStartTime(format: "MMM/dd/yyyy HH:mm:ss"))!
            newEventWindow.addSubview(field)
            
            // End Date
            let field2 = createDatePicker(x: 400/7 + 1, y: 400*CGFloat(7.0/9) - CGFloat(33.5*Double(1)), w: 400*5/7 - 4, h: 32)
            field2.dateValue = formatter.date(from: event.getEndTime(format: "MMM/dd/yyyy HH:mm:ss"))!
            newEventWindow.addSubview(field2)
            
            // Name
            let field3 = createField(placeholder: "Name", x: 400/7, y: 400*CGFloat(13.5/18.0) - CGFloat(34*2),
                                    w: 400*5/7 - 2, h: 35)
            field3.stringValue = event.getName()
            newEventWindow.addSubview(field3)
            
            //Flexibility
            let field4 = createField(placeholder: "Flexibility", x: 400/7, y: 400*CGFloat(13.5/18.0) - CGFloat(34*3),
                                     w: 400*5/7 - 2, h: 35)
            field4.stringValue = "Flexible"
            newEventWindow.addSubview(field4)
            
            // Location
            let field5 = createField(placeholder: "Location", x: 400/7, y: 400*CGFloat(13.5/18.0) - CGFloat(34*4),
                                     w: 400*5/7 - 2, h: 35)
            field5.stringValue = event.getLocation()
            newEventWindow.addSubview(field5)
            
            // Extra Information
            let field6 = createField(placeholder: "Extra Information", x: 400/7, y: 400*CGFloat(13.5/18.0) - CGFloat(34*5),
                                     w: 400*5/7 - 2, h: 35)
            field6.stringValue = event.getExtraInfo()
            newEventWindow.addSubview(field6)
            
            
        }
        
        else {
            
            let fields = ["Start Date", "End Date", "Name", "Priority", "Location", "Extra Information"]
            for i in 0...fields.endIndex-1 {
                
                // Add NSDatePicker if the field is a date
                if fields[i] == "Start Date" || fields[i] == "End Date" {
                    let field = createDatePicker(x: 400/7 + 1, y: 400*CGFloat(7.0/9) - CGFloat(33.5*Double(i)), w: 400*5/7 - 4, h: 32)
                    newEventFields.append(field)
                    newEventWindow.addSubview(field)
                }
                
                // Add NSTextField if the field is a string
                else {
                    let field = createField(placeholder: fields[i], x: 400/7, y: 400*CGFloat(13.5/18.0) - CGFloat(34*i),
                                            w: 400*5/7 - 2, h: 35)
                    field.stringValue = "1"
                    newEventFields.append(field)
                    newEventWindow.addSubview(field)
                }
                
            }
            
            let repeatButton = createButton(title: "Repeat", x: 400/7, y: 80, w: 400*5/7, h: 40)
            repeatButton.action = #selector(pressedRepeat)
            newEventWindow.addSubview(repeatButton)
            newEventFields.append(repeatButton)
            
            let saveButton = createButton(title: "Save", x: 400*4/7, y: 40, w: 400*2/7, h: 40)
            saveButton.action = #selector(saveNewEvent)
            newEventWindow.addSubview(saveButton)
            
        }
        
        let cancelButton = createButton(title: "Cancel", x: 400/7, y: 40, w: 400*2/7, h: 40)
        cancelButton.action = #selector(closeNewEvent)
        newEventWindow.addSubview(cancelButton)
        
        view.addSubview(newEventWindow)
    }
    
    override func awakeFromNib() {
        if view.window != nil {
            
            // Get screen dimensions
            width = (view.window?.screen?.visibleFrame.width)!
            height = (view.window?.screen?.visibleFrame.height)!
            
            // Add date title
            let str = String(milliToDate(time: Int(NSDate().timeIntervalSince1970)))
            myDateLabel = createLabel(title: str!, x: width/2 - width/12, y: height-75, w: width/6, h: 40)
            myDateLabel.font = calculateFont(toFit: self.myDateLabel, withString: self.myDateLabel.stringValue as NSString, minSize: 8, maxSize: 30)
            myDateLabel.wantsLayer = true
            myDateLabel.layer?.cornerRadius = 10
            view.addSubview(myDateLabel)
            
            // Add date change buttons
            let leftButton = createButton(title: "<", x:  width/2 - width/12 - 60, y: height-81, w: 50, h: 50)
            let rightButton = createButton(title: ">", x:  width/2 + width/12 + 10, y: height-81, w: 50, h: 50)
            leftButton.action = #selector(changeDate)
            rightButton.action = #selector(changeDate)
            view.addSubview(leftButton)
            view.addSubview(rightButton)
            
            // Add create button
            let createEventButton = createButton(title: "Create", x: 10, y: height-75, w: 70, h: 30)
            createEventButton.action = #selector(openNewEvent)
            view.addSubview(createEventButton)
            
            // Create calendar view
            let calendarView = createView(x: 0, y: 0, w: width, h: height-90, color: NSColor.white.cgColor)
            let calRect = calendarView.frame
            view.addSubview(calendarView)
            
            // Add labels buttons to calendar view
            for i in 1...24 {
                
                let myView = createView(
                    x: CGFloat(0 + Double(Int(i/13))*Double(width)/2),
                    y: CGFloat(12-i%13)*calRect.height/12 - CGFloat(Int(i/13))*calRect.height/12,
                    w: calRect.width/2,
                    h: calRect.height/12,
                    color: NSColor.white.cgColor)
                myView.layer?.borderWidth = 1
                myView.layer?.borderColor = NSColor.lightGray.cgColor
                
                let myLabel = createLabel(title: String((i+awakeTime-1)%24) + ":00", x: 0, y: 0, w: 75, h: calRect.height/12)
                myLabel.font = calculateFont(toFit: myLabel, withString: myLabel.stringValue as NSString, minSize: 8, maxSize: 20)
                myView.addSubview(myLabel)
                
                calendarView.addSubview(myView)
                hourContainers.append(myView)
            }
            
            let appDelegate = NSApplication.shared().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Plan")

            do {
                let results = try managedContext.fetch(fetchRequest)
                savedEvents = results as! [NSManagedObject]
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            eventList.initialise(data: savedEvents)
            reloadData()
        }
    }
    
}

