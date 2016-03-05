//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by azx on 15/12/12.
//  Copyright (c) 2015年 azx. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case NullaryOperation(String, () -> Double)
        case Variable(String)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .NullaryOperation(let symbol, _):
                    return symbol
                case .Variable(let symbol):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    private func learnOp(op: Op) {
        knownOps[op.description] = op
    }
    
    init() {
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 }) // inverse
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.NullaryOperation("π", { M_PI }))
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get { return opStack.map{ $0.description } }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                let numberFormatter = NSNumberFormatter()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = numberFormatter.numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    } else {
                        newOpStack.append(.Variable(opSymbol))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    // struct pass by value, class pass by reference
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op])
    {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .NullaryOperation(_, let operation):
                return (operation(), remainingOps)
            case .Variable(let symbol):
                return (variableValues[symbol], remainingOps)
            }
        }
        return(nil, ops)
    }
    
    private func pieceTogether(ops: [Op]) -> (completed: String?, remainings: [Op])
    {
        if !ops.isEmpty {
            var remainings = ops
            let op = remainings.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand.description, remainings)
            case .UnaryOperation(let symbol, _):
                let getTogether = pieceTogether(remainings)
                if let completed = getTogether.completed {
                    return ("\(symbol)(\(completed))", getTogether.remainings)
                } else {
                    return ("?", remainings)
                }
            case .BinaryOperation(let symbol, _):
                let getTogether1 = pieceTogether(remainings)
                if let completed1 = getTogether1.completed {
                    let getTogether2 = pieceTogether(getTogether1.remainings)
                    if let completed2 = getTogether2.completed {
                        if symbol == "×" || symbol == "÷" {
                            return ("(\(completed2)) \(symbol) (\(completed1))", getTogether2.remainings)
                        } else {
                            return ("\(completed2) \(symbol) \(completed1)", getTogether2.remainings)
                        }
                    } else {
                        return ("?", getTogether1.remainings)
                    }
                } else {
                    return ("?", remainings)
                }
            case .NullaryOperation(let symbol, _):
                return (symbol, remainings)
            case .Variable(let variable):
                return (variable, remainings)
            }
        }
        return (nil, ops)
    }
    
    var description: String? {
        get {
            var s = String()
            var stringCollect = Array<String>()
            if let completed = pieceTogether(opStack).completed {
                stringCollect.append(completed)
                var remainings = pieceTogether(opStack).remainings
                while let completedPlus = pieceTogether(remainings).completed {
                    stringCollect.append(completedPlus + ", ")
                    remainings = pieceTogether(remainings).remainings
                }
                for var index = stringCollect.endIndex - 1; index >= stringCollect.startIndex; index-- {
                    s += stringCollect[index]
                }
            }
            if s != "" {
                return s
            } else {
                return nil
            }
        }
    }
    
    func evaluate() -> Double? {
        let (result, _) = evaluate(opStack)
        //println("\(opStack) = \(result) with \(remainer) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    var variableValues = [String: Double]()
    
    func setOperand(value: Double, symbol: String) -> Double? {
        self.variableValues[symbol] = value
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func clearStock() {
        opStack.removeAll(keepCapacity: true)
    }
    
    func undoStock() -> Double? {
        if let variable = opStack.last {
            if variable.description != "M" {
                opStack.removeLast()
                return evaluate()
            } else {
                opStack.removeAtIndex(opStack.endIndex - 1)
            }
        }
        return nil
    }
}