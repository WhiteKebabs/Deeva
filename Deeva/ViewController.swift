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
    var newEventFields = [String:AnyObject]()
    var newEventFieldTitles = [String:NSTextField]()
    var myDateLabel = NSTextField()
    var currDate = String()
    var newEventWindow = NSView()
    var newEventBackground = NSView()
    var flexRadio = [NSButton]()
    var repRadio = [NSButton]()
    
    // Event fields
    var savedEvents = [NSManagedObject]()
    var eventList = EventList()
    var eventButtons: [NSButton] = []
    var buttonEventMap =  [String: Event]()
    var displayedEvent = String()
    
    // Array of field names that will be used as the titles onscreen and keys for storing in the newEventFields dictionary
    let titles = ["Name", "Start", "End", "Location", "Details", "Flexibility", "Color", "Repeats"]
    
    let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    func swapRadio(button:NSButton){
        if button.title == "Flexible" {flexRadio[0].state = NSOffState; flexRadio[1].state = NSOnState}
        else {flexRadio[1].state = NSOffState; flexRadio[0].state = NSOnState}
    }
    
    func changeDate(button: NSButton){
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd yyyy"
        var currentDateTime = Double((formatter.date(from: currDate)?.timeIntervalSince1970)!)
        if button.title == "<" { currentDateTime -= 8.64e+4 }
        else { currentDateTime += 8.64e+4 }
        let newTime = milliToDate(time: Int(currentDateTime))
        currDate = newTime
        myDateLabel.stringValue = getDayOfWeek(today: newTime) + " " + newTime
        reloadData()
    }
    
    func reloadData(){
        
        // Clear data
        buttonEventMap =  [String: Event]()
        
        // Remove all event buttons on display
        for button in eventButtons {
            button.removeFromSuperview()
        }
        
        // Convert the current date to a key for retrieving events
        let key = currDate.replacingOccurrences(of: " ", with: "/")
        let currDayEvents = eventList.getDate(date: key)
        
        // Find width of button area
        let buttonArea = (width-150)/2
        
        // Loop through all hours in currDayEvent
        for var i in 0...24 {
            
            let j = i
            
            var list = [Event]()
            if j < 24 {
                // Loop through all events occuring in the hour
                if (currDayEvents?[String((i+awakeTime)%24)]) == nil { continue }
                else { list = (currDayEvents?[String((i+awakeTime)%24)])! }
            }
            else {
                if eventList.getRepeated(day: getDayOfWeek(today: currDate)) == nil { break }
                else { list = eventList.getRepeated(day: getDayOfWeek(today: currDate))! }
            }
            
            for event in list {
                
                // Add necessary number of buttons for event duration
                var start = Int(event.getStartTime(format: "mm"))!
                let startHour = Int(event.getStartTime(format: "HH"))!// Add
                let end = Int(event.getEndTime(format: "mm"))!
                let endHour = Int(event.getEndTime(format: "HH"))! - 9
                
                if j == 24 {
                
                    i = startHour - 9
                
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM dd yyyy"
                    let currentDateTime = Double((formatter.date(from: currDate)?.timeIntervalSince1970)!)
                    let eventStartTime = Double((formatter.date(from: event.getStartTime(format: "MMM dd yyyy"))?.timeIntervalSince1970)!)
                    let repeats = event.getRepeats()
                    formatter.dateFormat = "MMM/dd/yyyy"
                    let eventEndTime = Double((formatter.date(from: repeats[0])?.timeIntervalSince1970)!)
                
                    if currentDateTime < eventStartTime || currentDateTime > eventEndTime { continue }
                }
                
                while i <= endHour {
                    
                    let title = event.getName() + "\n" + event.getStartTime(format: "HH:mm") +
                        " - " + event.getEndTime(format: "HH:mm")
                    let x = 75 + buttonArea*CGFloat(Double(start)/Double(60))
                    var w = buttonArea*CGFloat(Double(end-start)/Double(60))
                    let color = event.getColor()
                    let colors = color.components(separatedBy: " ")
                    var colorss = [CGFloat]()
                    for i in colors {
                        if let n = NumberFormatter().number(from: i){
                            colorss.append(CGFloat(n))
                        }
                    }
                    
                    var hourIndex:Int = 0
                    if j < 24 { hourIndex = j }
                    else { hourIndex = (j+awakeTime+6)%24 }
                    
                    // If the button to the end of the hour
                    if i < endHour {
                        w = buttonArea*CGFloat(Double(60-start)/Double(60))
                        start = 0
                    }
                    
                    let button = createButton(title:title, x:x, y:0, w:w, h:hourContainers[hourIndex].frame.height)
                    let layer = CALayer()
                    layer.backgroundColor = CGColor(red: colorss[0], green: CGFloat(colorss[1]), blue: CGFloat(colorss[2]), alpha: 1.0)
                    //button.layer = layer
                    button.action = #selector(openEventDisplay)
                    hourContainers[i].addSubview(button)
                    eventButtons.append(button)
                    buttonEventMap[title] = event
                    i += 1
                }
            }
            i = j
        }
        
    }
    
    func deleteEvent(){
        /*
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd YYYY HH:mm"
        let currEvent = buttonEventMap[displayedEvent]
        
        var i = 0
        for event in savedEvents {
            if event.value(forKey: "name") as? String == currEvent?.getName() &&
                formatter.string(from: event.value(forKey: "startDate") as! Date) == currEvent?.getStartTime(format: "MMM dd yyyy HH:mm") {
                
                managedContext.delete(event)
                savedEvents.remove(at: i)
                
                do {
                    try managedContext.save()
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }

                _ = eventList.deleteEvent(event: currEvent!)
                
                closeNewEvent()
                reloadData()
                
                return
                
            }
            i += 1
        }*/
    }
    
    func pressedRepeat(button:NSButton){
        
        // If the
        if button.title == "No" {repRadio[0].state = NSOffState; repRadio[1].state = NSOnState}
        
        else {
            repRadio[0].state = NSOffState; repRadio[1].state = NSOnState
            
            newEventWindow.setFrameSize(NSSize(width: 400, height: 550))
            newEventWindow.setFrameOrigin(NSPoint(x:newEventWindow.frame.origin.x, y:newEventWindow.frame.origin.y-80))
            for i in 0...titles.count-1 {
                let field = newEventFields[titles[i]] as AnyObject
                field.setFrameOrigin(NSPoint(x:(newEventFields[titles[i]]?.frame.origin.x)!, y:(newEventFields[titles[i]]?.frame.origin.y)!+160))
                let field2 = newEventFieldTitles[titles[i]]! as NSTextField
                field2.setFrameOrigin(NSPoint(x:(newEventFieldTitles[titles[i]]?.frame.origin.x)!, y:(newEventFieldTitles[titles[i]]?.frame.origin.y)!+160))
            }
            flexRadio[1].setFrameOrigin(NSPoint(x:(flexRadio[1].frame.origin.x), y:(flexRadio[1].frame.origin.y)+160))
            repRadio[1].setFrameOrigin(NSPoint(x:(repRadio[1].frame.origin.x), y:(repRadio[1].frame.origin.y)+160))
            for i in 0...6 {
                let button = NSButton(frame:NSRect(x:100 + 100*Int(Double(i)/4.0), y:205 - 30*(i%4) , width:100, height:30))
                button.bezelStyle = NSRegularSquareBezelStyle
                button.title = days[i]
                button.setButtonType(.switch)
                newEventFields[days[i]] = button
                newEventWindow.addSubview(button)
            }
            
            let field = createDatePicker(x: 400/7 + 1, y: 400/10 + 45, w: 400*5/7 - 2, h: 22)
            newEventWindow.addSubview(field)
            newEventFields["RepeatDate"] = field
            
        }
    }
    
    func saveNewEvent(){

        // Connect to core data
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "Plan", in:managedContext)
        let plan = NSManagedObject(entity: entity!, insertInto: managedContext)

        // Extract NSDatePicker date values
        let newStartDate = (newEventFields["Start"] as! NSDatePicker).dateValue
        let newEndDate = (newEventFields["End"] as! NSDatePicker).dateValue
        
        // Extract button color
        let color = (newEventFields["Color"] as! NSButton).layer?.backgroundColor?.components
        var colors_arr = [String]()
        for i in color! { colors_arr.append(String(describing: i)) }
        let colors = colors_arr.joined(separator:" ")
        
        // Extract repeat days
        var repeatDays = [String]()
        if (newEventFields["Repeats"] as! NSButton).state == NSOffState {
            for i in 7...13 {
                if (newEventFields[days[i]] as! NSButton).state == NSOnState{
                    repeatDays.append(days[i])
                }
            }
        }
        var rep = ""
        if repeatDays.count > 0 {
            let endDate = newEventFields["RepeatDate"] as! NSDatePicker
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM/dd/yyyy"
            repeatDays.insert(formatter.string(from: endDate.dateValue), at: 0)
            rep = repeatDays.joined(separator: " ")
        }
        
        // Add event to data structure
        _ = eventList.addEvent(name: (newEventFields["Name"]?.stringValue)! as String, startDate:newStartDate, endDate:newEndDate,
                           flexible: newEventFields["Repeats"]?.state == NSOnState, repeats: rep,
                           location:(newEventFields["Location"]?.stringValue)!,
                           extraInfo:(newEventFields["Details"]?.stringValue)!, color:colors)
        
        // Create NSManagedObject
        plan.setValue((newEventFields["Name"] as! NSTextField).stringValue, forKey: "name")
        plan.setValue(newStartDate, forKey: "startDate")
        plan.setValue(newEndDate, forKey: "endDate")
        plan.setValue(rep, forKey: "repeats")
        plan.setValue((newEventFields["Location"] as! NSTextField).stringValue, forKey: "location")
        plan.setValue((newEventFields["Details"] as! NSTextField).stringValue, forKey: "extraInfo")
        plan.setValue(colors, forKey:"color")
        
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
    
    func openColorPanel(){
        let cp = NSColorPanel.shared()
        cp.setTarget(self)
        cp.setAction(#selector(colorDidChange))
        cp.makeKeyAndOrderFront(self)
        cp.isContinuous = true
    }
    
    func openEventDisplay(button:NSButton){
        
        // Create the window for the fields
        newEventWindow = createView(x: width/2 - 200, y: height/2 - 200, w: 400, h: 400, color:NSColor(netHex:/*0xecf0f1*/0xffffff).cgColor)
        newEventWindow.layer?.cornerRadius = 10
        
        // Create a blurry panel to prevent interactions with buttons in the background
        newEventBackground = createBlurView(x:0, y:0, w:width, h:height)
        self.view.addSubview(newEventBackground)
        
        // Initial frame values
        let x:CGFloat = 130; let y:CGFloat = 350; let w:CGFloat = 220; let h:CGFloat = 23
        
        // Event name field
        let nameField = createField(placeholder: "Tap here to enter...", x: x, y: y, w: w, h: h)
        
        // Event start date field
        let startField = createDatePicker(x: x, y: y-35, w: w, h: h)
        
        // Event end date field
        let endField = createDatePicker(x: x, y: y-70, w: w, h: h)
        
        // Event location field
        let locField = createField(placeholder: "Tap here to enter...", x: x, y: y-105, w: w, h: h)
        
        // Event extra information field
        let infoField = createField(placeholder: "Tap here to enter...", x: x, y: y-140, w: w, h: h)
        
        // Radio buttons for selecting flexibility of event
        flexRadio = createRadios(t:["Not Flexible", "Flexible"], a:#selector(swapRadio), x:[x+20,x+w/2+20], y:[y-175,y-175], w:[w/2,w/2], h:[h,h])
        newEventWindow.addSubview(flexRadio[1])
        
        // Radio buttons for selecting whether the event repeats
        repRadio = createRadios(t:["No", "Yes"], a:#selector(pressedRepeat), x:[x+20,x+w/2+20], y:[y-245,y-245], w:[w/2,w/2], h:[h,h])
        newEventWindow.addSubview(repRadio[1])
        
        // Button for changing colour associated with event
        let colorButton = createButton(title:"Tap to select color", x: x, y: y-210, w: w, h: h)
        colorButton.bezelStyle = NSRoundedBezelStyle
        colorButton.action = #selector(openColorPanel)
        
        // Array of field objects
        let f = [nameField, startField, endField, locField, infoField, flexRadio[0], colorButton, repRadio[0]]
        
        for i in 0...f.count-1 {
            let title = createLabel(title: titles[i], x: 50, y: f[i].frame.origin.y, w: 70, h: f[i].frame.height)
            f[i].wantsLayer = true
            f[i].layer?.borderWidth = 2
            f[i].layer?.borderColor = NSColor.white.cgColor
            title.layer?.borderWidth = 2
            title.layer?.borderColor = NSColor.white.cgColor
            title.textColor = NSColor.lightGray
            title.alignment = .right
            newEventWindow.addSubview(title)
            newEventWindow.addSubview(f[i])
            newEventFieldTitles[titles[i]] = title
            newEventFields[titles[i]] = f[i] // Add field to newEventFields dictionary with key as name
        }
        
        // If the user is creating a new event
        if button.title != "Create" {
            (newEventFields["Name"] as! NSTextField).stringValue = (buttonEventMap[button.title]?.getName())!
            (newEventFields["Location"] as! NSTextField).stringValue = (buttonEventMap[button.title]?.getLocation())!
            (newEventFields["Details"] as! NSTextField).stringValue = (buttonEventMap[button.title]?.getExtraInfo())!
            if (buttonEventMap[button.title]?.isFlexible())! {flexRadio[1].state = NSOnState} else {flexRadio[0].state = NSOnState}
            
        }
        
        let cancel = createButton(title: "Cancel", x: 400/7, y: 40, w: 400*2/7, h: 40)
        cancel.action = #selector(closeNewEvent)
        newEventWindow.addSubview(cancel)
        
        let save = createButton(title: "Save", x: 400*4/7, y: 40, w: 400*2/7, h: 40)
        save.action = #selector(saveNewEvent)
        newEventWindow.addSubview(save)
        
        self.view.addSubview(newEventWindow)

    }
    
    func colorDidChange(sender:NSColorPanel) {
        let layer = CALayer()
        layer.backgroundColor =
            CGColor(red: sender.color.redComponent, green: sender.color.greenComponent, blue: sender.color.blueComponent, alpha: 1.0)
        (newEventFields["Color"] as! NSButton).layer = layer
        (newEventFields["Color"] as! NSButton).title = ""
        (newEventFields["Color"] as! NSButton).layer?.cornerRadius = 5
    }
    
    override func awakeFromNib() {
        if view.window != nil {
            
            // Get screen dimensions
            width = (view.window?.screen?.visibleFrame.width)!
            height = (view.window?.screen?.visibleFrame.height)!
            
            // Add date title
            var str = String(milliToDate(time: Int(NSDate().timeIntervalSince1970)))
            currDate = str!
            str = getDayOfWeek(today: str!) + " " + str!
            myDateLabel = createLabel(title: str!, x: width/2 - width/6, y: height-75, w: width/3, h: 40)
            myDateLabel.font = calculateFont(toFit: self.myDateLabel, withString: self.myDateLabel.stringValue as NSString, minSize: 8, maxSize: 30)
            myDateLabel.wantsLayer = true
            myDateLabel.layer?.cornerRadius = 10
            view.addSubview(myDateLabel)
            
            // Add date change buttons
            let leftButton = createButton(title: "<", x:  width/2 - width/6 - 60, y: height-81, w: 50, h: 50)
            let rightButton = createButton(title: ">", x:  width/2 + width/6 + 10, y: height-81, w: 50, h: 50)
            leftButton.action = #selector(changeDate)
            rightButton.action = #selector(changeDate)
            view.addSubview(leftButton)
            view.addSubview(rightButton)
            
            // Add create button
            let createEventButton = createButton(title: "Create", x: 10, y: height-75, w: 70, h: 30)
            createEventButton.action = #selector(openEventDisplay)
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

