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
            init(title: String, value: String, unit: String, keyPath: WritableKeyPath<Scenario, Float>) {
                self.title = title
                self.value = Variable<String>(value)
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
    
    static var initial: ScenarioViewModel = ScenarioViewModel(title: "Can I retire early?",
                                                              scenario: Scenario.initial)
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
        let allItems = sections.reduce([Section.Item]()) { return $0 + $1.items }
        return Observable.merge(allItems.map { $0.value.asObservable() })
            .map { _ in
                var scenario = Scenario.zero
                allItems.forEach { scenario[keyPath: $0.keyPath] = Float($0.value.value) ?? 0 }
                return scenario
            }
    }
    
    var result: Observable<String> {
        return scenario.map {
            $0.estateValue > 0 ? "You can retire 🎉. Your estate value will be \($0.estateValue)" : "Unfortunately you cannot retire with this scenario ☹️"
        }
    }

    convenience init(title: String, scenario: Scenario) {
        let personalInfo = [\Scenario.currentAge, \Scenario.retirementAge,
                           \Scenario.currentFund, \Scenario.savings,
                           \Scenario.retirementExpense]
        let assumptions = [\Scenario.lifeExpectancy, \Scenario.returnRate, \Scenario.inflation]
        let sections = [
            Section(header: "Personal info", items: personalInfo.map {
                ScenarioViewModel.Section.Item(scenario: scenario, keyPath: $0)
            }),
            Section(header: "Assumptions", items: assumptions.map {
                ScenarioViewModel.Section.Item(scenario: scenario, keyPath: $0)
            })
        ]
        
        self.init(title: Variable<String>(title), sections: sections)
    }
}

extension ScenarioViewModel.Section.Item {
    convenience init(scenario: Scenario, keyPath: WritableKeyPath<Scenario, Float>) {
        let meta = keyPath.metadata
        self.init(title: meta.title, value: String(scenario[keyPath: keyPath]),
                  unit: meta.unit, keyPath: keyPath)
    }
}
