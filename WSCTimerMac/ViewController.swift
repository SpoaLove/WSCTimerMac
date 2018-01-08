//
//  ViewController.swift
//  WSCTimerMac
//
//  Created by Tengoku no Spoa on 2017/12/29.
//  Copyright © 2017年 Tengoku no Spoa. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    //Initialize labels
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var timeLabel: NSTextField!
    
    //Initialize time Variables
    var minutes: UInt8 = 0
    var seconds: UInt8 = 0
    var fraction: UInt8 = 0
    
    //Initialize Phase Counter
    var phaseCount: Int = 0
    
    //Determine Phase Status
    func setCurrentStatus( PhaseCount: Int) -> String {
        let PhaseCount = PhaseCount
        switch PhaseCount {
        case 0:
            return "WSC Timer Pwapp"
        case 1:
            return "Preparation"
        case 2:
            return "Affrimative Speaker 1"
        case 6:
            return "Affrimative Speaker 2"
        case 10:
            return "Affrimative Speaker 3"
        case 4:
            return "Negative Speaker 1"
        case 8:
            return "Negative Speaker 2"
        case 12:
            return "Negative Speaker 3"
        case 3,5,7,9,11:
            return "Discussion"
        case 13:
            return "Feedback Preparation"
        case 14:
            return "Feedback Negative"
        case 15:
            return "Feedback Affrimative"
        default:
            return "End!"
        }
    }
    
    @IBAction func startButtonDidPressed(_ sender: NSButton) {
        
        if (!timer.isValid) {
            
            //run update Time repeativelly
            let aSelector : Selector = #selector(ViewController.updateTime)
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            
            //run Time Alert check repeativelly
            let bSelector: Selector = #selector(ViewController.timeAlert)
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: bSelector, userInfo: nil, repeats: true)
            
            //run End phase check  repeativelly
            let cSelector : Selector = #selector(ViewController.checkIfEndOfPhase)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: cSelector, userInfo: nil, repeats: true)
            // define start time
            startTime = NSDate.timeIntervalSinceReferenceDate
            
        }
        
        //continue to next phase
        phaseCount += 1
        //set status label to corresponding phase
        statusLabel.stringValue = setCurrentStatus(PhaseCount: phaseCount)
    }
    
    @IBAction func endButtonDidPressed(_ sender: NSButton) {
        timer.invalidate()
    }
    
    @IBAction func resetButtonDidPressed(_ sender: NSButton) {
        reset()
    }
    
    @objc func updateTime() {
        if timer.isValid {
            let currentTime = NSDate.timeIntervalSinceReferenceDate
            
            var elapsedTime: TimeInterval = currentTime - startTime
            
            minutes = UInt8(elapsedTime / 60.0)
            elapsedTime -= (TimeInterval(minutes) * 60)
            
            //calculate the seconds in elapsed time.
            seconds = UInt8(elapsedTime)
            elapsedTime -= TimeInterval(seconds)
            
            //find out the fraction of milliseconds to be displayed.
            fraction = UInt8(elapsedTime * 100)
            
            //add the leading zero for minutes, seconds and millseconds and store them as string constants
            let strMinutes = String(format: "%02d", minutes)
            let strSeconds = String(format: "%02d", seconds)
            let strFraction = String(format: "%02d", fraction)
            timeLabel.stringValue = "\(strMinutes):\(strSeconds):\(strFraction)"
        }
    }
    
    // reset function
    func reset() {
        phaseCount = 0
        let alert = NSAlert()
        alert.messageText = "Reset?"
        alert.informativeText = "Do you want to reset?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        if(alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn){
            phaseCount = 0
            timer.invalidate()
            timeLabel.stringValue = "00:00:00"
            statusLabel.stringValue = setCurrentStatus(PhaseCount: phaseCount)
        }
    }

    // Check if the phase reach end
    @objc func checkIfEndOfPhase(){
        if statusLabel.stringValue == "End!"{
            reset()
        }
    }
    
    //initializing timer & timer variables
    var startTime = TimeInterval()
    var timer:Timer = Timer()
    
    // function for displaying alert
    func displayAlert(message:String, title:String, buttonText:String){
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = title
        alert.alertStyle = .warning
        alert.addButton(withTitle: buttonText)
        alert.runModal()
    }
    
    //Alert function
    @objc func timeAlert() {
        
        //determine phase type
        switch phaseCount {
            
        case 1://Type 1-Preparation stage, 15min
            if minutes==15 && seconds==0 {
                displayAlert(message: "End of Discussion", title: "Times Up!", buttonText: "Dismiss")
            }
        case 2,6,10,4,8,12://Type 2-Debate Speech, 4min each
            //3 min alert
            if minutes==3 && seconds==0 {
                displayAlert(message: "1 Minute Remaining", title: "Times Alert!", buttonText: "Dismiss")
            }
                //4 min alert
            else if minutes==4 && seconds==0 {
                displayAlert(message: "The time is up!", title: "Times Up!", buttonText: "Dismiss")

            }
        case 3,5,7,9,11://Type 3- Group Discussion, 1min each
            if minutes==1 && seconds==0 {
                displayAlert(message: "End of Discussion!", title: "Times Up!", buttonText: "Dismiss")
            }
            
        case 13...15://Type 4- Feedbacks, 1:30min each
            if minutes==1 && seconds==30 {
                displayAlert(message: "The time is up!", title: "Times Up!", buttonText: "Dismiss")
            }
        default:
            break
        }
    }
    

    

    

}

