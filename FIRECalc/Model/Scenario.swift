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
}
