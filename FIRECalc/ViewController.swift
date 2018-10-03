//
//  ViewController.swift
//  FIRECalc
//
//  Created by Mamnun on 3/10/18.
//  Copyright © 2018 Octron. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var resultLabel: UILabel!
    
    let viewModel: ScenarioViewModel = ScenarioViewModel.initial
    let disposeBag = DisposeBag()
    var dataSource: RxTableViewSectionedAnimatedDataSource<ScenarioViewModel.Section>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        viewModel.title.asObservable().bind(to: rx.title).disposed(by: disposeBag)
        viewModel.result
            .bind(to: resultLabel.rx.text)
            .disposed(by: disposeBag)
        dataSource = RxTableViewSectionedAnimatedDataSource<ScenarioViewModel.Section>(
            configureCell: { ds, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as? ItemCell
                    else { return UITableViewCell() }
                cell.titleLabel.text = item.title
                cell.valueTextField.text = item.value.value
                cell.valueTextField.rx.text
                    .orEmpty
                    .bind(to: item.value)
                .disposed(by: self.disposeBag)
                cell.unitLabel.text = item.unit
                return cell
            },
            titleForHeaderInSection:{ ds, index in
                return ds.sectionModels[index].header
            }
        )
        
        Observable.just(viewModel.sections)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}

class ItemCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueTextField: UITextField!
    @IBOutlet var unitLabel: UILabel!
}
