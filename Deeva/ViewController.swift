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
    
    var eventList = EventList()

    // Dimensions
    var awakeTime = 9
    var buttons_columns = 75 // NOT NEEDED
    var calRect = NSRect()
    var width = CGFloat()
    var height = CGFloat()
    
    // Outlets
    var hourContainers: [NSView] = [] // NEEDED
    var hourLabels: [NSTextField] = [] // NOT NEEDED
    var newEventFields: [NSTextField] = [] // CLEAR DATA AFTER USAGE
    var newEventDates: [NSDatePicker] = [] // CLEAR DATA AFTER USAGE
    var myDateLabel = NSTextField() // NEEDED
    var newEventWindow = NSView() // NEEDED
    var newEventBackground = NSView() // NEEDED
    
    // Current date
    var currentDateTime = Date().timeIntervalSince1970 // NOT NEEDED
    
    // Event fields
    var fields = ["Start Date", "End Date", "Name", "Priority", "Location", "Extra Information"]
    var savedEvents = [NSManagedObject]() // NEED
    var eventButtons: [NSButton] = [] // PROBABLY NEED
    var currEvent = NSManagedObject() // PROBABLY NEED
    var buttonEventMap =  [String: NSManagedObject]() // CLEAR DATA AFTER USAGE
    var repeatDays: [String] = [] // CLEAR DATA AFTER USAGE
    var repeatButton = NSButton() // NOT NEEDED

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func changeDate(button: NSButton){
        if button.title == "<" { currentDateTime -= 8.64e+4 }
        else { currentDateTime += 8.64e+4 }
        myDateLabel.stringValue = milliToDate(time: Int(currentDateTime))
        reloadData()
    }
    
    func reloadData(){
        
        for button in eventButtons {
            button.removeFromSuperview()
        }
        
        let key = myDateLabel.stringValue.replacingOccurrences(of: " ", with: "/")
        let currDayEvents = eventList.getDate(date: key)
        
        for i in 0...23 {
            String((i+awakeTime)%24)
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
    
    func displayEventDetails(button:NSButton){
        
        newEventWindow = createView(x: width/2 - 400/2, y: height/2 - 400/2,
                                    w: 400, h: 400, color: NSColor.lightGray.cgColor)
        
        let title = button.title.components(separatedBy: ["\n"])
        let key = myDateLabel.stringValue + " " + title[0] + " " + title[1]
        let event = buttonEventMap[key]
        
        // Generate Fields
        let vals = [event?.value(forKey: "name") as! String]
        for i in 0...vals.endIndex-1 {
            let field = createLabel(title: vals[i], x: 400/7, y: 400*CGFloat(Double(15-2*i)/18.0),
                                    w: 400*5/7, h: 400/10)
            newEventFields.append(field)
            newEventWindow.addSubview(field)
        }
        
        let deleteButton = createButton(title: "Delete", x: 400/7, y: 400/10,
                                        w: 400*2/7, h: 400/10)
        currEvent = event!
        
        deleteButton.action = #selector(deleteEvent)
        newEventWindow.addSubview(deleteButton)
        
        let cancelButton = createButton(title: "Cancel", x: 400*4/7, y: 400/10,
                                        w: 400*2/7, h: 400/10)
        cancelButton.action = #selector(closeNewEvent)
        newEventWindow.addSubview(cancelButton)
        
        view.addSubview(newEventWindow)
        
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
            
            button.state = NSOffState
            newEventWindow.setFrameSize(NSSize(width: 400, height: 550))
            newEventWindow.setFrameOrigin(NSPoint(x:newEventWindow.frame.origin.x, y:newEventWindow.frame.origin.y-80))
            for i in 0...newEventDates.count-1 {
                newEventDates[i].setFrameOrigin(NSPoint(x:newEventDates[i].frame.origin.x, y:newEventDates[i].frame.origin.y+160))
            }
            for i in 0...newEventFields.count-1 {
                newEventFields[i].setFrameOrigin(NSPoint(x:newEventFields[i].frame.origin.x, y:newEventFields[i].frame.origin.y+160))
            }
            for i in 0...6 {
                let button = NSButton(frame:NSRect(x:100 + 100*Int(Double(i)/4.0), y:205 - 30*(i%4) , width:100, height:30))
                button.bezelStyle = NSRegularSquareBezelStyle
                button.title = days[i]
                button.action = #selector(pressedRepeatDay)
                repeatDays.append(button.title)
                newEventWindow.addSubview(button)
            }
            repeatButton.setFrameOrigin(NSPoint(x:repeatButton.frame.origin.x, y:repeatButton.frame.origin.y+160))
            
            let field = createDatePicker(x: 400/7 + 1, y: 400/10 + 40, w: 400*5/7 - 2, h: 35)
            newEventWindow.addSubview(field)
            
        }
    }
    
    func saveNewEvent(){
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "Plan", in:managedContext)
        let plan = NSManagedObject(entity: entity!, insertInto: managedContext)

        let newStartDate = newEventDates[0].dateValue
        let newEndDate = newEventDates[1].dateValue
        
        _ = eventList.addEvent(name: newEventFields[0].stringValue as String, startDate:newStartDate, endDate:newEndDate,
                           flexible: newEventFields[1].stringValue.toBool()!, repeats: repeatDays,
                           location:newEventFields[2].stringValue, extraInfo:newEventFields[3].stringValue)
        
        plan.setValue(newEventFields[0].stringValue, forKey: "name")
        plan.setValue(newStartDate, forKey: "startDate")
        plan.setValue(newEndDate, forKey: "endDate")
        plan.setValue(Int(newEventFields[1].stringValue)!, forKey: "priority")
        plan.setValue(newEventFields[2].stringValue, forKey: "location")
        plan.setValue(newEventFields[3].stringValue, forKey: "extraInfo")
        
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
        
        newEventWindow = createView(x: width/2 - 200, y: height/2 - 200, w: 400, h: 400, color:NSColor(netHex:0xecf0f1).cgColor)
        newEventWindow.layer?.cornerRadius = 10
        
        
        newEventBackground = createBlurView(x:0, y:0, w:width, h:height)
        self.view.addSubview(newEventBackground)
        
        // Generate Fields
        for i in 0...fields.endIndex-1 {
            
            if fields[i] == "Start Date" || fields[i] == "End Date" {
                let field = createDatePicker(x: 400/7 + 1, y: 400*CGFloat(Double(14.0)/18.0) - CGFloat(33.5*Double(i)),
                                          w: 400*5/7 - 4, h: 32)
                newEventDates.append(field)
                newEventWindow.addSubview(field)
            }
            
            else {
                let field = createField(placeholder: self.fields[i], x: 400/7, y: 400*CGFloat(13.5/18.0) - CGFloat(34*i),
                                        w: 400*5/7 - 2, h: 35)
                field.stringValue = "1"
                newEventFields.append(field)
                newEventWindow.addSubview(field)
            }
        }
        
        repeatButton = createButton(title: "Repeat", x: 400/7, y: 80, w: 400*5/7, h: 40)
        repeatButton.action = #selector(pressedRepeat)
        newEventWindow.addSubview(repeatButton)
        
        let saveButton = createButton(title: "Save", x: 400*4/7, y: 40, w: 400*2/7, h: 40)
        saveButton.action = #selector(saveNewEvent)
        newEventWindow.addSubview(saveButton)
        
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
            let str = String(milliToDate(time: Int(currentDateTime)))
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
            calRect = calendarView.frame
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
                hourLabels.append(myLabel)
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
            savedEvents = sort(arr: savedEvents)
            reloadData()
 
        }
    }
    
}

