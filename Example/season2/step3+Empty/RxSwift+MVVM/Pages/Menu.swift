//
//  Menu.swift
//  RxSwift+MVVM
//
//  Created by MinKyeongTae on 2020/06/27.
//  Copyright © 2020 iamchiwon. All rights reserved.
//

// MARK: - Menu

import Foundation

// MARK: Model

// - View를 위한 모델, ViewModel
struct Menu {
    var id: Int
    var name: String
    var price: Int
    var count: Int
}

extension Menu {
    static func fromMEnuItems(id: Int, item: MenuItem) -> Menu {
        return Menu(id: id, name: item.name, price: item.price, count: 0)
    }
}
