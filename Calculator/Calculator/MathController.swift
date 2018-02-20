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
    func mathController(_ controller: MathController, changedOperationTo operation: MathController.Operation)
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
    
    /*!
        Set the provided number as an operand for the MathController to perform an operation with.  If it successfully sets the operand, it will notify its delegate.  If all both operands are already set, it will throw an error.
     */
    func pushOperand(_ operand: Double) throws {
        if firstOperand == nil {
            firstOperand = operand
            delegate?.mathController(self, changedFirstOperandTo: operand)
        }else if secondOperand == nil {
            secondOperand = operand
            delegate?.mathController(self, changedSecondOperandTo: operand)
        }else{
            throw MathControllerError.tooManyOperands
        }
    }
    
    func pushOperator(_ operation: Operation){
        if (self.operation == nil || self.operation != operation) && secondOperand == nil {
            self.operation = operation
            delegate?.mathController(self, changedOperationTo: operation)
        }else if firstOperand != nil && secondOperand != nil && self.operation != nil {
            performSelectedOperation()
        }
    }
    
    func performSelectedOperation(){
        guard let firstOperand = firstOperand, let operation = operation else {
            NSLog("Tried to perform math with no operation or no operand. It didn't work.")
            return
        }
        let secondOperand = self.secondOperand != nil ? self.secondOperand! : firstOperand
        self.firstOperand = nil
        self.secondOperand = nil
        self.operation = nil
        switch operation {
        case .add:
            delegate?.mathController(self, performedOperationWithResult: firstOperand + secondOperand)
        case .subtract:
            delegate?.mathController(self, performedOperationWithResult: firstOperand - secondOperand)
        case .multiply:
            delegate?.mathController(self, performedOperationWithResult: firstOperand * secondOperand)
        case .divide:
            delegate?.mathController(self, performedOperationWithResult: firstOperand / secondOperand)
        }
    }
    
}
