//
//  ViewController.swift
//  Calculator
//
//  Created by Christopher Thiebaut on 2/19/18.
//  Copyright © 2018 Christopher Thiebaut. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var mainDisplayLabel: UILabel!
    
    //MARK: - OperationButtons
    @IBOutlet weak var multiplyButton: UIButton!
    @IBOutlet weak var divideButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var subtractButton: UIButton!
    
    var selectedButton: UIButton?
    
    var displayNumber: Double = 0
    var hasDecimal = false
    let numberFormatter = NumberFormatter()
    let mathController = MathController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 10
        mathController.delegate = self
    }
    
    
    @IBAction func digitTapped(_ sender: UIButton) {
        
        guard let buttonText = sender.titleLabel?.text else {
            NSLog("Invalid digit button pressed.  Button had no text.")
            return
        }
        guard var displayString = mainDisplayLabel.text else {
            fatalError("Invalid state.  Main display was blank.")
        }
        
        if !hasDecimal || displayString.contains("."){
            displayString += "\(buttonText)"
        }else{
            displayString += ".\(buttonText)"
        }
        
        guard let number = Double(displayString) else {
            fatalError("Addition of new digit could not be processed because it did not form a valid double when appended to the display.")
        }
        
        displayNumber = number
        
        updateDisplay()
    }
    
    @IBAction func backspaceTapped(_ sender: UIButton) {
        guard let displayString = mainDisplayLabel.text else {
            return
        }
        var substringToKeep = displayString.prefix(displayString.count - 1)
        if let lastChar = substringToKeep.last {
            if String(lastChar) == "." {
                _ = substringToKeep.popLast()
                hasDecimal = false
            }
            if substringToKeep.last == "-"{
                substringToKeep = "0"
            }
            guard let newNumber = Double(String(substringToKeep)) else{
                fatalError("Result of backspace cannot be converted to Double")
            }
            displayNumber = newNumber
            
        }else{
            displayNumber = 0
            hasDecimal = false
        }
        
        updateDisplay()
    }
    
    @IBAction func plusMinusTapped(_ sender: UIButton) {
        displayNumber *= -1
        updateDisplay()
    }
    
    @IBAction func decimalTapped(_ sender: UIButton) {
        if floor(displayNumber) < displayNumber {
            NSLog("Decimal pressed on decimal number.")
            return
        }
        hasDecimal = true
    }
    
    //MARK: - Operators
    
    @IBAction func additionButtonTapped(_ sender: UIButton) {
        pushOperand()
        mathController.pushOperator(MathController.Operation.add)
    }
    
    @IBAction func performOperation() {
        pushOperand()
        mathController.performSelectedOperation()
    }
    
    private func pushOperand(){
        do{
            try mathController.pushOperand(displayNumber)
            displayNumber = 0
            updateDisplay()
        }catch let error {
            NSLog("Error pushing operand in preparation to push operator: \(error.localizedDescription)")
        }
    }
    
    private func updateDisplay(){
        let number = NSNumber(value: displayNumber)
        guard let displayString = numberFormatter.string(from: number)  else {
            NSLog("Error updating display.  Incompatible number format for numberFormatter.")
            return
        }
        mainDisplayLabel.text = displayString
    }
    
    private func updateSelectedButtonTo(_ button: UIButton){
        selectedButton?.isHighlighted = false
        selectedButton = button
        button.isHighlighted = true
    }
}

extension CalculatorViewController : MathControllerDelegate {
    func mathController(_ controller: MathController, changedFirstOperandTo operand: Double) {
        //TODO: update an auxiliary display to show an operation in progress.
    }
    
    func mathController(_ controller: MathController, changedSecondOperandTo operand: Double) {
        //Doesn't need to do anything at this time.
    }
    
    func mathController(_ controller: MathController, changedOperationTo operation: MathController.Operation) {
        switch operation {
        case .add:
            updateSelectedButtonTo(addButton)
        case .subtract:
            updateSelectedButtonTo(subtractButton)
        case .multiply:
            updateSelectedButtonTo(multiplyButton)
        case .divide:
            updateSelectedButtonTo(divideButton)
        }
    }
    
    func mathController(_ controller: MathController, performedOperationWithResult result: Double) {
        displayNumber = result
        updateDisplay()
    }
    
    
}
