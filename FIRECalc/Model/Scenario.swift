//
//  Scenario.swift
//  FIRECalc
//
//  Created by Mamnun on 4/10/18.
//  Copyright © 2018 Octron. All rights reserved.
//

import Foundation

struct Scenario {
    var currentAge: Float
    var retirementAge: Float
    var currentFund: Float
    var savings: Float // monthly
    var retirementExpense: Float // monthly
    
    // assumptions
    var lifeExpectancy: Float
    var returnRate: Float
    var inflation: Float
    
    var estateValue: Float {
        let af = 1.0 + returnRate / 100 //accumulator factor
        var result = savings * (1 - pow(af, retirementAge-currentAge)) / (1 - af) * pow(af, lifeExpectancy - retirementAge)
        result -= retirementExpense * (1 - pow(af, lifeExpectancy - retirementAge)) / (1 - af)
        result += currentFund * pow(af, lifeExpectancy - currentAge)
        
        return result
    }
    
    static let initial = Scenario(currentAge: 30, retirementAge: 40, currentFund: 5000, savings: 3000, retirementExpense: 4500, lifeExpectancy: 95, returnRate: 8, inflation: 3)
    
    static let zero = Scenario(currentAge: 0, retirementAge: 0, currentFund: 0, savings: 0, retirementExpense: 0, lifeExpectancy: 0, returnRate: 0, inflation: 0)
}

extension PartialKeyPath where Root == Scenario {
    typealias Metadata = (title: String, unit: String)
    var metadata: Metadata {
        switch self {
        case \Scenario.currentAge:
            return (title: "Age", unit: "years")
        case \Scenario.retirementAge:
            return (title: "Retirement age", unit: "years")
        case \Scenario.currentFund:
            return (title: "Current fund", unit: "$")
        case \Scenario.savings:
            return (title: "Monthly savings", unit: "$")
        case \Scenario.retirementExpense:
            return (title: "Retirement expense", unit: "$")
        case \Scenario.lifeExpectancy:
            return (title: "Life Expectancy", unit: "years")
        case \Scenario.returnRate:
            return (title: "Return Rate", unit: "%")
        case \Scenario.inflation:
            return (title: "Inflation", unit: "%")
        default:
            return (title: "", unit: "")
        }
    }
}
