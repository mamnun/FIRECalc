//
//  ScenarioViewModel.swift
//  FIRECalc
//
//  Created by Mamnun on 4/10/18.
//  Copyright © 2018 Octron. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

public class ScenarioViewModel {
    public class Section: AnimatableSectionModelType {
        public class Item {
            let title: String
            let value: Variable<String>
            let unit: String
            let keyPath: WritableKeyPath<Scenario, Float>
            init(title: String, value: Variable<String>, unit: String, keyPath: WritableKeyPath<Scenario, Float>) {
                self.title = title
                self.value = value
                self.unit = unit
                self.keyPath = keyPath
            }
        }
        public let header: String
        public var items: [Item]
        init(header: String, items: [Item]) {
            self.header = header
            self.items = items
        }
        public var identity : String {
            return header
        }
        
        required public init(original: ScenarioViewModel.Section, items: [Item]) {
            self.header = original.header
            self.items = items
        }
    }
    let title: Variable<String>
    let sections: [Section]
    init(title: Variable<String>, sections: [Section]) {
        self.title = title
        self.sections = sections
    }
}


extension ScenarioViewModel.Section.Item: IdentifiableType, Equatable {
    public var identity : String {
        return title
    }
    public static func == (lhs: ScenarioViewModel.Section.Item, rhs: ScenarioViewModel.Section.Item) -> Bool {
        return lhs.title == rhs.title
    }
}

extension ScenarioViewModel {
    var scenario: Observable<Scenario> {
        let observables = sections
            .reduce([Section.Item]()) { result, section in
                return result + section.items
            }
            .map { $0.value.asObservable()}
        return Observable.merge(observables)
            .map { _ in
                var sc = Scenario(currentAge: 0, retirementAge: 0, currentFund: 0, savings: 0, retirementExpense: 0, lifeExpectancy: 0, returnRate: 0, inflation: 0)
                self.sections
                    .reduce([Section.Item]()) { result, section in
                        return result + section.items
                    }
                    .forEach({ item in
                        sc[keyPath: item.keyPath] = Float(item.value.value) ?? 0
                    })
                return sc
            }
    }
    
    var result: Observable<String> {
        return scenario.map {
            if $0.estateValue > 0 {
                return "You can retire 🎉. your estate value will be \($0.estateValue)"
            } else {
                return "Unfortunately you cannot retire at this scenario ☹️"
            }
        }
    }
    // this initialization can be done a bit more elegantly :(
    static var initial: ScenarioViewModel {
        return ScenarioViewModel(title: Variable<String>("Can I retire early?"), sections: [
            Section(header: "Personal info", items: [
                Section.Item(title: "Age", value: Variable<String>("30"), unit: "y", keyPath: \Scenario.currentAge),
                Section.Item(title: "Retirement age", value: Variable<String>("45"), unit: "y", keyPath: \Scenario.retirementAge),
                Section.Item(title: "Current fund", value: Variable<String>("5000"), unit: "$", keyPath: \Scenario.currentFund),
                Section.Item(title: "Monthly savings", value: Variable<String>("5000"), unit: "$", keyPath: \Scenario.savings),
                Section.Item(title: "Retirement expense", value: Variable<String>("4500"), unit: "$", keyPath: \Scenario.retirementExpense)
                ]),
            Section(header: "Assumptions", items: [
                Section.Item(title: "Life Expectancy", value: Variable<String>("95"), unit: "y", keyPath: \Scenario.lifeExpectancy),
                Section.Item(title: "Return Rate", value: Variable<String>("8"), unit: "%", keyPath: \Scenario.returnRate),
                Section.Item(title: "Inflation", value: Variable<String>("3"), unit: "%", keyPath: \Scenario.inflation)
                ])
            ])
    }
}
