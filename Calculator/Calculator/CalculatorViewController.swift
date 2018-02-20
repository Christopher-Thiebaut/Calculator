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
    @IBOutlet weak var secondaryDisplayLabel: UILabel!
    
    //MARK: - OperationButtons
    @IBOutlet weak var multiplyButton: UIButton!
    @IBOutlet weak var divideButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var subtractButton: UIButton!
    
    //MARK: - Store Buttons
    
   
    
    
    //MARK: - Stateful Properties
    
    var selectedButton: UIButton?
    var displayNumber: Double = 0 {
        didSet {
            
        }
    }
    var hasDecimal = false
    var showingAnswer = false
    var pushedOperand = false
    let mathController = MathController()
    
    
    let numberFormatter = NumberFormatter()
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 10
        mathController.delegate = self
    }
    
    //MARK: - Number Building Methods
    
    @IBAction func digitTapped(_ sender: UIButton) {
        
        pushedOperand = false
        
        if showingAnswer {
            mainDisplayLabel.text = "0"
            showingAnswer = false
        }
        
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
        if showingAnswer {
            displayNumber = 0
            updateDisplay()
            showingAnswer = false
            return
        }
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
    
    @IBAction func subtractionButtonTapped(_ sender: UIButton) {
        pushOperand()
        mathController.pushOperator(MathController.Operation.subtract)
    }
    
    @IBAction func multiplicationButtonTapped(_ sender: UIButton) {
        pushOperand()
        mathController.pushOperator(MathController.Operation.multiply)
    }
    
    @IBAction func divisionButtonTapped(_ sender: UIButton) {
        pushOperand()
        mathController.pushOperator(MathController.Operation.divide)
    }
    
    @IBAction func performOperation() {
        pushOperand()
        mathController.performSelectedOperation()
    }
    
    //MARK: - Private Helper Methods
    
    private func pushOperand(){
        guard !pushedOperand else {
            NSLog("Did not push operand because the user hasn't done any input since an operand was pushed.")
            return
        }
        do{
            try mathController.pushOperand(displayNumber)
            showingAnswer = true
//            displayNumber = 0
//            updateDisplay()
            pushedOperand = true
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
    
    private func updateSelectedButtonTo(_ button: UIButton?){
        selectedButton?.layer.borderWidth = 0
        selectedButton = nil
        guard let button = button else {
            return
        }
        selectedButton = button
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.white.cgColor
    }
    
    private func appendToSecondaryDisplay(_ text: String){
        guard let secondaryText = secondaryDisplayLabel.text else {
            NSLog("Cannot update secondary display with operator because there is no operand.")
            return
        }
        secondaryDisplayLabel.text = "\(secondaryText) \(text)"
    }
}

//MARK: - MathControllerDelegate
extension CalculatorViewController : MathControllerDelegate {
    func mathController(_ controller: MathController, changedFirstOperandTo operand: Double) {
        let operandWrapper = NSNumber(value: operand)
        guard let operandString = numberFormatter.string(from: operandWrapper) else {
            fatalError("Received non-numerical operator.")
        }
        secondaryDisplayLabel.text = operandString
    }
    
    func mathController(_ controller: MathController, changedSecondOperandTo operand: Double) {
        let operandWrapper = NSNumber(value: operand)
        guard let operandString = numberFormatter.string(from: operandWrapper) else {
            fatalError("Received non-numerical operator.")
        }
        appendToSecondaryDisplay(operandString)
    }
    
    func mathController(_ controller: MathController, changedOperationTo operation: MathController.Operation?) {
        guard let operation = operation else {
            updateSelectedButtonTo(nil)
            return
        }
        switch operation {
        case .add:
            updateSelectedButtonTo(addButton)
            appendToSecondaryDisplay("+")
        case .subtract:
            updateSelectedButtonTo(subtractButton)
            appendToSecondaryDisplay("-")
        case .multiply:
            updateSelectedButtonTo(multiplyButton)
            appendToSecondaryDisplay("x")
        case .divide:
            updateSelectedButtonTo(divideButton)
            appendToSecondaryDisplay("÷")
        }
    }
    
    func mathController(_ controller: MathController, performedOperationWithResult result: Double) {
        displayNumber = result
        updateDisplay()
        showingAnswer = true
        pushedOperand = false
    }
}
