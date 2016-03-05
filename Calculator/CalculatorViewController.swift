//
//  ViewController.swift
//  Calculator
//
//  Created by azx on 15/12/6.
//  Copyright (c) 2015年 azx. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController
{
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var history: UILabel!
    
    private var brain = CalculatorBrain()
    
    var userIsInTheMiddleOfTypingNumber: Bool  = false
    var existPoint: Bool = false
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!

        if existPoint && digit == "." {
            userIsInTheMiddleOfTypingNumber = false
            display.text = "error!"
            existPoint = false
        } else {
            if digit == "." {
                existPoint = true
            }
            if userIsInTheMiddleOfTypingNumber {
                display.text = display.text! + digit
            } else {
                display.text = digit
                userIsInTheMiddleOfTypingNumber = true
                if let historyText = brain.description {
                    history.text = historyText + " ="
                }
            }
        }
    }
    
    var firstOperation = true
    var valueMinus = false
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        if firstOperation {
            history.text = ""
            firstOperation = false
        }
        
        if userIsInTheMiddleOfTypingNumber && operation != "+/-" {
            enter()
        }
        
        if let result = brain.performOperation(operation) {
            displayValue = result
        } else {
            displayValue = nil
        }
    }
    
    
    @IBAction func minus() {
        valueMinus = !valueMinus
    }
    
    
    @IBAction func undo() {
        if display.text != "" && userIsInTheMiddleOfTypingNumber {
            display.text! = String(display.text!.characters.dropLast())
        } else if !userIsInTheMiddleOfTypingNumber {
            displayValue = brain.undoStock()
        }
    }
    @IBAction func clear() {
        display.text = " "
        history.text = " "
        brain.clearStock()
        firstOperation = true

    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingNumber = false
        existPoint = false
        if let displayText = displayValue {
            if let result = brain.pushOperand(displayText) {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
        
        
        valueMinus = false
    }
    
    @IBAction func pushM() {
        enter()
        if let result = brain.pushOperand("M") {
            displayValue = result
        } else {
            displayValue = nil
        }
    }
    
    @IBAction func setM() {
        if let displayV = displayValue {
            if let result = brain.setOperand(displayV, symbol: "M") {
                displayValue = result
            }
        }
        userIsInTheMiddleOfTypingNumber = false
        
    }
    

    var displayValue: Double? {
        get {
            if valueMinus {
                if let displayText = display.text {
                    if let displayNumber = NSNumberFormatter().numberFromString("-" + displayText) {
                        return displayNumber.doubleValue
                    }
                }
            } else {
                if let displayText = display.text {
                    if let displayNumber = NSNumberFormatter().numberFromString(displayText) {
                        return displayNumber.doubleValue
                    }
                }
            }
            return nil
        }
        set {
            if newValue != nil {
                display.text = "\(newValue!)"
            } else {
                display.text = "0"
            }
            
            userIsInTheMiddleOfTypingNumber = false
            
            if let hisoryText = brain.description {
                history.text = hisoryText + " ="
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as? UIViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController
        }
        if let gvc = destination as? GraphViewController {
            if let identifier = segue.identifier {
                switch identifier {
                    case "Show Graph":
                        if let title = brain.description {
                            gvc.title = title.componentsSeparatedByString(", ").last
                            gvc.program = brain.program
                        } else {
                            gvc.title = "Graph"
                        }
                default: break
                }
            }
        }
    }
    
}

