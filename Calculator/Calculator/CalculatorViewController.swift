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
    @IBOutlet weak var storeButton1: UIButton!
    @IBOutlet weak var storeLabel1: UILabel!
    var storedNumber1: Double?
    @IBOutlet weak var storeButton2: UIButton!
    @IBOutlet weak var storeLabel2: UILabel!
    var storedNumber2: Double?
    
    
    
    //MARK: - Stateful Properties
    
    var selectedButton: UIButton?
    var displayNumber: Double = 0 {
        didSet {
            updateStoreButtonStates()
        }
    }
    var hasDecimal = false {
        didSet{
            if !hasDecimal {
                numberFormatter.minimumFractionDigits = 0
            }
        }
    }
    var showingAnswer = false
    var pushedOperand = false
    let mathController = MathController()
    
    
    let numberFormatter = NumberFormatter()
    let maxDigits = 15
    let maxDecimalDigits = 10
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = maxDecimalDigits
        numberFormatter.maximumIntegerDigits = maxDigits
        numberFormatter.positiveInfinitySymbol = "Error"
        numberFormatter.negativeInfinitySymbol = "Error"
        mathController.delegate = self
        
        Styler.applyStyles()
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
        
        let splitByDecimal = displayString.split(separator: ".")
        
        //Check and see if the user is still allowed to add more digits. If not, the button press should do nothing.
        if !hasDecimal && splitByDecimal[0].count >= maxDigits{
            return
        }else if splitByDecimal.count > 1 && hasDecimal && splitByDecimal[1].count >= maxDecimalDigits  {
            return
        }
        
        if !displayString.contains(".") && hasDecimal{
            displayString += "."
            numberFormatter.minimumFractionDigits += 1
        }
        displayString += "\(buttonText)"
        
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
    
    @IBAction func storeButton1Tapped(_ sender: UIButton) {
        if let storedNumber = storedNumber1, displayNumber == 0{
            displayNumber = storedNumber
            updateDisplay()
            pushedOperand = false
        }else if displayNumber != 0 {
            storedNumber1 = displayNumber
            updateStoreButtonStates()
        }
    }
    
    @IBAction func storeButton2Tapped(_ sender: UIButton) {
        if let storedNumber = storedNumber2, displayNumber == 0{
            displayNumber = storedNumber
            updateDisplay()
            pushedOperand = false
        }else if displayNumber != 0 {
            storedNumber2 = displayNumber
            updateStoreButtonStates()
        }
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
            displayNumber = 0
            hasDecimal = false
            updateDisplay()
            pushedOperand = true
        }catch let error {
            NSLog("Error pushing operand in preparation to push operator: \(error.localizedDescription)")
        }
    }
    
    private func updateDisplay(){
        if let displayString = numberAsString(displayNumber) {
            mainDisplayLabel.text = displayString
        }
    }
    
    private func numberAsString(_ number: Double) -> String? {
        //TODO: Make another temporary number formatter for displaying on the buttons as the other one is now stateful.
        let numberWrapper = NSNumber(value: number)
        if abs(number) < pow(Double(10), Double(maxDigits)){
            guard let displayString = numberFormatter.string(from: numberWrapper)  else {
                NSLog("Error prducing string for number.  Incompatible number format for numberFormatter.")
                return nil
            }
            return displayString
        }else{
            let bigNumberFormatter = NumberFormatter()
            bigNumberFormatter.numberStyle = .scientific
            bigNumberFormatter.positiveFormat = "0.###E+0"
            bigNumberFormatter.negativeFormat = "-0.###E+0"
            guard let displayString = bigNumberFormatter.string(from: numberWrapper) else{
                NSLog("Error producing string for number.  Incompatible number format for numberFormatter.")
                return nil
            }
            return displayString
        }
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
    
    private func removeOperatorFromSecondaryDisplay(){
        guard var secondaryText = secondaryDisplayLabel.text else {
            NSLog("Cannot remove operator from secondary display text because there is no text.")
            return
        }
        secondaryText = secondaryText.components(separatedBy: CharacterSet.whitespaces)[0]
        secondaryDisplayLabel.text = secondaryText
    }
    
    private func updateStoreButtonStates(){
        updateStoreButtonState(storeButton1, buttonLabel: storeLabel1, storedValue: storedNumber1)
        updateStoreButtonState(storeButton2, buttonLabel: storeLabel2, storedValue: storedNumber2)
    }
    
    private func updateStoreButtonState(_ button: UIButton, buttonLabel: UILabel, storedValue: Double?){
        
        if let storedValue = storedValue {
            guard let storedValueString = numberAsString(storedValue) else {
                fatalError("Stored number could not be displayed on button because it's not a valid number.")
            }
            button.setTitle(storedValueString, for: .normal)
            if displayNumber == 0 {
                buttonLabel.text = "Use"
                button.backgroundColor = UIColor.green
            }else{
                buttonLabel.text = "Overwrite:"
                button.backgroundColor = UIColor.red
            }
        }else{
            button.backgroundColor = UIColor.green
            buttonLabel.text = "Store:"
            guard let displayedValueString = numberAsString(displayNumber) else {
                fatalError("Displayed number could not be displayed on button because it's not a valid number.")
                }
            setButtonTitleWithoutAnimation(button: button, title: displayedValueString)
        }
    }
    
    private func setButtonTitleWithoutAnimation(button: UIButton, title: String){
        UIView.performWithoutAnimation {
            button.setTitle(title, for: .normal)
            button.layoutIfNeeded()
        }
    }
}

//MARK: - MathControllerDelegate
extension CalculatorViewController : MathControllerDelegate {
    func mathController(_ controller: MathController, changedFirstOperandTo operand: Double) {
        guard let operandString = numberAsString(operand) else {
            fatalError("Received non-numerical operator.")
        }
        secondaryDisplayLabel.text = operandString
    }
    
    func mathController(_ controller: MathController, changedSecondOperandTo operand: Double) {
        guard let operandString = numberAsString(operand) else {
            fatalError("Received non-numerical operator.")
        }
        appendToSecondaryDisplay(operandString)
    }
    
    func mathController(_ controller: MathController, changedOperationTo operation: MathController.Operation?) {
        guard let operation = operation else {
            updateSelectedButtonTo(nil)
            return
        }
        
        removeOperatorFromSecondaryDisplay()
        
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
