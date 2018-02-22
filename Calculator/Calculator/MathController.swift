//
//  MathStack.swift
//  Calculator
//
//  Created by Christopher Thiebaut on 2/19/18.
//  Copyright © 2018 Christopher Thiebaut. All rights reserved.
//

import Foundation

protocol MathControllerDelegate: class {
    func mathController(_ controller: MathController, changedFirstOperandTo operand: Double)
    func mathController(_ controller: MathController, changedSecondOperandTo operand: Double)
    func mathController(_ controller: MathController, changedOperationTo operation: MathController.Operation?)
    func mathController(_ controller: MathController, performedOperationWithResult: Double)
}

class MathController {
    
    weak var delegate: MathControllerDelegate?
    
    private var firstOperand: Double? = nil
    private var secondOperand: Double? = nil
    private var operation: Operation? = nil
    
    enum Operation {
        case multiply
        case divide
        case add
        case subtract
    }
    
    enum MathControllerError: Error {
        case tooManyOperands
    }
    
    init() {
        
    }
    
    /**
        Set the provided number as an operand for the MathController to perform an operation with.  If it successfully sets the operand, it will notify its delegate.  If all both operands are already set, it will throw an error.
     - parameter operand: A Double that can be used in a calculation later.
     */
    func pushOperand(_ operand: Double) throws {
        if firstOperand == nil {
            firstOperand = operand
            delegate?.mathController(self, changedFirstOperandTo: operand)
        }else if secondOperand == nil {
            secondOperand = operand
            delegate?.mathController(self, changedSecondOperandTo: operand)
        }else{
            performSelectedOperation()
            throw MathControllerError.tooManyOperands
        }
    }
    
    /**
        Stores the provided operation for later calculation. If there are already an operation and 2 operands, the first operation will be performed before the pushed one is saved.
     - parameter operation: A member of MathController.Operation specifying which operation should be performed.
     */
    func pushOperator(_ operation: Operation){
        if (self.operation == nil || self.operation != operation) && secondOperand == nil {
            self.operation = operation
            delegate?.mathController(self, changedOperationTo: operation)
        }else if firstOperand != nil && secondOperand != nil && self.operation != nil {
            performSelectedOperation(chainingOperation: operation)
        }
    }
    
    /**
     Perform the specified operation and notify the delegate  of its results.
    */
    func performSelectedOperation() {
        performSelectedOperation(chainingOperation: nil)
    }
    
    private func performSelectedOperation(chainingOperation: Operation? = nil){
        guard let firstOperand = firstOperand else {
            NSLog("Tried to perform math with no operand. It didn't work.")
            return
        }
        
        guard let operation = operation else {
            self.firstOperand = nil
            self.secondOperand = nil
            delegate?.mathController(self, performedOperationWithResult: firstOperand)
            return
        }
        
        let secondOperand = self.secondOperand != nil ? self.secondOperand! : firstOperand
        
        delegate?.mathController(self, changedOperationTo: nil)
        var result: Double
        switch operation {
        case .add:
            result = firstOperand + secondOperand
        case .subtract:
            result = firstOperand - secondOperand
        case .multiply:
            result = firstOperand * secondOperand
        case .divide:
            result = firstOperand / secondOperand
        }
        
        if chainingOperation == nil {
            self.firstOperand = nil
            self.secondOperand = nil
            self.operation = nil
        }else{
            self.firstOperand = result
            delegate?.mathController(self, changedFirstOperandTo: result)
            self.operation = chainingOperation
            delegate?.mathController(self, changedOperationTo: chainingOperation)
            self.secondOperand = nil
        }
        
        delegate?.mathController(self, performedOperationWithResult: result)
    }
    
}
