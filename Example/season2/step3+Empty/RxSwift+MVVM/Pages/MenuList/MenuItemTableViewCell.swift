//
//  MenuItemTableViewCell.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 07/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

// MARK: - MenuItemTableViewCell

import UIKit

class MenuItemTableViewCell: UITableViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var count: UILabel!
    @IBOutlet var price: UILabel!

    // MARK: Cell 내에서의 viewModel 사용

    var onChange: ((Int) -> Void)?

    @IBAction func onIncreaseCount() {
        onChange?(+1)
    }

    @IBAction func onDecreaseCount() {
        onChange?(-1)
    }
}
