//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by MinKyeongTae on 2020/06/27.
//  Copyright © 2020 iamchiwon. All rights reserved.
//

import Foundation

class MenuListViewModel {
    let menuList: [Menu] = [
        Menu(name: "튀김", price: 600, count: 16),
        Menu(name: "오뎅", price: 500, count: 30),
        Menu(name: "떡볶이", price: 1200, count: 20),
        Menu(name: "순대", price: 700, count: 13),
    ]
}
