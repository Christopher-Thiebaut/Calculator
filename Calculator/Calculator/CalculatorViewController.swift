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
    var storedNumber1: Double? {
        didSet {
            PersistenceController.save(values: (displayNumber,storedNumber1,storedNumber2))
        }
    }
    @IBOutlet weak var storeButton2: UIButton!
    @IBOutlet weak var storeLabel2: UILabel!
    var storedNumber2: Double?{
        didSet {
            PersistenceController.save(values: (displayNumber,storedNumber1,storedNumber2))
        }
    }

    //MARK: - Stateful Properties
    
    var selectedButton: UIButton?
    var displayNumber: Double = 0 {
        didSet {
            updateStoreButtonStates()
            PersistenceController.save(values: (displayNumber,storedNumber1,storedNumber2))
        }
    }
    var hasDecimal = false {
        didSet{
            if !hasDecimal {
                numberFormatter.minimumFractionDigits = 0
            }
        }
    }
    var overwriteDisplayedNumber = false
    var pushedOperand = false
    let mathController = MathController()
    
    let numberFormatter = NumberFormatter()
    let maxDigits = 15
    let maxDecimalDigits = 10
    let positiveInfinitySymbol = "Error"
    let negativeInfinitySymbol = "Error"
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = maxDecimalDigits
        numberFormatter.maximumIntegerDigits = maxDigits
        mathController.delegate = self
        
        let values = PersistenceController.loadValues()
        if let stored1 = values?.storedValue1 {
            storedNumber1 = stored1
        }
        if let stored2 = values?.storedValue2 {
            storedNumber2 = stored2
        }
        if let screen = values?.screen {
            displayNumber = screen
        }
        overwriteDisplayedNumber = true
        updateDisplay()
        updateStoreButtonStates()
    }

    
    //MARK: - Number Building Methods
    /**
        Append a digit represented by the button which was tapped to the number being displayed, or replace the number with the digit if the number being displayed was the result of a previous calculation. Also, the calculator only supports numbers of a certain size, so nothing will be appended if the calculator has reached that limit.
     */
    @IBAction func digitTapped(_ sender: UIButton) {
        
        pushedOperand = false
        
        if overwriteDisplayedNumber {
            mainDisplayLabel.text = "0"
            overwriteDisplayedNumber = false
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
    
    /**
        Remove the last digit from the number being displayed. If the number being displayed is the result of a previous calculation, the whole number is deleted as the assumption is the user wants to clear it in order to perform new calculations.
     */
    @IBAction func backspaceTapped(_ sender: UIButton) {
        if overwriteDisplayedNumber {
            displayNumber = 0
            updateDisplay()
            overwriteDisplayedNumber = false
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
        if overwriteDisplayedNumber {
            displayNumber = 0
            updateDisplay()
        }
    }
    
    /**
        If there is a non-zero number being displayed, saves it to this button's associated stored value.  If not, enters this button's associated stored value as the value being displayed.
     */
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
    
    /**
     If there is a non-zero number being displayed, saves it to this button's associated stored value.  If not, enters this button's associated stored value as the value being displayed.
     */
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
    /**
        If the number being displayed has not already been sent to the mathController, sends the number being displayed to the mathController as an operand and marks the number being displayed as overwiteable so the next change will replace it instead of appending to it.  The displayed number is not reset to zero because that would create a situation in which it appears to the user they are about to perform an operation with zero, but the operation would be performed with the most recent value instead.
     */
    private func pushOperand(){
        guard !pushedOperand else {
            NSLog("Did not push operand because the user hasn't done any input since an operand was pushed.")
            return
        }
        do{
            try mathController.pushOperand(displayNumber)
            displayNumber = 0
            hasDecimal = false
            overwriteDisplayedNumber = true
//            updateDisplay()
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
    /**
    Produce a string representing the provided number.
     - parameter number: A double representing the number you want a String for
     - parameter useDefaultNumberFormatter: If true, uses the number formatter owned by the view controller, otherwise creates a temporary number formatter with reasonable defaults.
     - returns: A String representing number
     */
    private func numberAsString(_ number: Double , useDefaultNumberFormatter: Bool = true) -> String? {
        var formatter: NumberFormatter
        if useDefaultNumberFormatter {
            formatter = numberFormatter
        }else{
            formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = maxDecimalDigits
            formatter.maximumIntegerDigits = maxDigits
        }
        let numberWrapper = NSNumber(value: number)
        if abs(number) < pow(Double(10), Double(maxDigits)){
            guard let displayString = formatter.string(from: numberWrapper)  else {
                NSLog("Error prducing string for number.  Incompatible number format for numberFormatter.")
                return nil
            }
            return displayString
        }else{
            let bigNumberFormatter = NumberFormatter()
            bigNumberFormatter.numberStyle = .scientific
            bigNumberFormatter.positiveFormat = "0.###E+0"
            bigNumberFormatter.negativeFormat = "-0.###E+0"
            bigNumberFormatter.positiveInfinitySymbol = positiveInfinitySymbol
            bigNumberFormatter.negativeInfinitySymbol = negativeInfinitySymbol
            guard let displayString = bigNumberFormatter.string(from: numberWrapper) else{
                NSLog("Error producing string for number.  Incompatible number format for numberFormatter.")
                return nil
            }
            return displayString
        }
    }
    
    /**
        Use this function and its associated property to mark for the user which operand is currently selected by giving it a white border.
    */
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
    
    /**
        Appends the specified text to the secondary display which is right above the main display that shows the result of calculations. The secondary display is meant to show the next operation to be performed by displaying any operands or operator that have already been selected.
     */
    private func appendToSecondaryDisplay(_ text: String){
        guard let secondaryText = secondaryDisplayLabel.text else {
            NSLog("Cannot update secondary display with operator because there is no operand.")
            return
        }
        secondaryDisplayLabel.text = "\(secondaryText) \(text)"
    }
    
    /**
        Use this function to remove any operator present in the secondary display while keeing any text that was before the operator (like an operand). This is usually done because the user switched what operator is selected and you need to remove the old one from the display before adding the new one.
     */
    private func removeOperatorFromSecondaryDisplay(){
        guard var secondaryText = secondaryDisplayLabel.text else {
            NSLog("Cannot remove operator from secondary display text because there is no text.")
            return
        }
        secondaryText = secondaryText.components(separatedBy: CharacterSet.whitespaces)[0]
        secondaryDisplayLabel.text = secondaryText
    }
    
    /**
        Update the appearance of the store value buttons to make it clear to the user what pressing the button in the current context will do.
    */
    private func updateStoreButtonStates(){
        updateStoreButtonState(storeButton1, buttonLabel: storeLabel1, storedValue: storedNumber1)
        updateStoreButtonState(storeButton2, buttonLabel: storeLabel2, storedValue: storedNumber2)
        if storeLabel1.text == storeLabel2.text {
            storeLabel2.isHidden = true
        }else{
            storeLabel2.isHidden = false
        }
    }
    
    /**
        Update the state of the provided button and label based on the provided storedValue and the number on the main display.
     - parameter button: The button to be updated. This should probably be storeButton1 or storeButton2.
     - parameter buttonLabel: A label to update with the function the button will perform if pressed. The label should be visually associated with the button if this is going to make any sense. This is expected to be storeLabel1 or storeLabel2 (whichever is associated with the provided button).
     - parameter storedValue: This should be storedNumber1 or storedNumber2, whichever is associated with the provided button.
    */
    private func updateStoreButtonState(_ button: UIButton, buttonLabel: UILabel, storedValue: Double?){
        
        if let storedValue = storedValue {
            guard let storedValueString = numberAsString(storedValue, useDefaultNumberFormatter: false) else {
                fatalError("Stored number could not be displayed on button because it's not a valid number.")
            }
            button.setTitle(storedValueString, for: .normal)
            if displayNumber == 0 {
                buttonLabel.text = "Use:"
                button.backgroundColor = UIColor.customGreen
            }else{
                buttonLabel.text = "Overwrite:"
                button.backgroundColor = UIColor.customRed
            }
        }else{
            button.backgroundColor = UIColor.customGreen
            buttonLabel.text = "Store:"
            guard let displayedValueString = numberAsString(displayNumber, useDefaultNumberFormatter: false) else {
                fatalError("Displayed number could not be displayed on button because it's not a valid number.")
                }
            setButtonTitleWithoutAnimation(button: button, title: displayedValueString)
        }
    }
    
    /**
        Changes the button's title without the usual fade in-out animation which accompanies most button title changes. This is needed so that the storedValueButtons' titles can be updated while the user is typing a number.  With the animation, the button would usually be blank until the user finished input.
     */
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
        overwriteDisplayedNumber = true
        pushedOperand = false
    }
}

extension UIColor {
    static var customGreen : UIColor {
        return #colorLiteral(red: 0.1855942309, green: 0.7683538198, blue: 0.7147178054, alpha: 1)
    }
    static var customRed : UIColor {
        return #colorLiteral(red: 0.9044539332, green: 0.1141348854, blue: 0.2119770348, alpha: 1)
    }
    
}
