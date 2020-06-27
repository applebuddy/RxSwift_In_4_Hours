//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by MinKyeongTae on 2020/06/27.
//  Copyright © 2020 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

class MenuListViewModel {
    // - menuObservable은 [Menu]를 받습니다. [Menu]값이 주어질때마다 Observable이 계속 동작을 한다.
    // - BehaviorSubject는 생성 시점부터 초기값을 갖는다.
    var menuObservable = BehaviorSubject<[Menu]>(value: [])

    // - 아이템 총 합을 구해서 방출하는 Observable
    lazy var itemsCount = menuObservable.map {
        $0.map { $0.count }.reduce(0, +)
    }

    // 가격 총 합을 구해서 방출하는 Observable
    lazy var totalPrice = menuObservable.map {
        $0.map { $0.price * $0.count }.reduce(0, +)
    }

    // MARK: Subject의 사용

    // var totalPrice: PublishSubject<Int> = PublishSubject()

    // MARK: Init

    init() {
        let menuList: [Menu] = [
            Menu(name: "튀김", price: 600, count: 16),
            Menu(name: "오뎅", price: 500, count: 30),
            Menu(name: "떡볶이", price: 1200, count: 20),
            Menu(name: "순대", price: 700, count: 13),
        ]

        menuObservable.onNext(menuList)
    }

    // - clearButton을 누를때마다 아래의 stream이 생긴다.
    func clearAllItemSelections() {
        menuObservable
            .map { menuList in
                menuList.map { menu in
                    Menu(name: menu.name, price: menu.price, count: 0)
                }
            }
            .take(1) // 1번만 수행함을 의미
            .subscribe(onNext: {
                self.menuObservable.onNext($0)
            })
    }
}
