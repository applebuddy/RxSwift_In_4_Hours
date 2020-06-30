//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by MinKyeongTae on 2020/06/27.
//  Copyright © 2020 iamchiwon. All rights reserved.
//

// MARK: - ViewModel

// - ViewModel에서 이벤트에 대해 모델을 뷰에 어떻게 적용해야할지를 정의합니다.
// - 예를들어 + - 버튼 동작에 대한 동작 및 에러처리 등은 ViewModel이 알고 있게 됩니다.
// - 화면에 어떤 내용을 그려야할 지를 ViewModel에서 가지고 있고, 처리하게 됩니다.

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
            Menu(id: 0, name: "튀김", price: 600, count: 16),
            Menu(id: 1, name: "오뎅", price: 500, count: 30),
            Menu(id: 2, name: "떡볶이", price: 1200, count: 20),
            Menu(id: 3, name: "순대", price: 700, count: 13),
        ]

        menuObservable.onNext(menuList)
    }

    // - clearButton을 누를때마다 아래의 stream이 생긴다.
    func clearAllItemSelections() {
        menuObservable
            .map { menuList in
                menuList.map { menu in
                    Menu(id: menu.id, name: menu.name, price: menu.price, count: 0)
                }
            }
            .take(1) // 1번만 수행함을 의미
            .subscribe(onNext: {
                self.menuObservable.onNext($0)
            })
    }

    func changeCount(item: Menu, increase: Int) {
        menuObservable
            .map { menuList in
                menuList.map { menu in
                    // 동일 아이템일 경우에는 값을 증가, 그 외에는 현상 유지
                    if menu.id == item.id {
                        return Menu(id: menu.id,
                                    name: menu.name,
                                    price: menu.price,
                                    count: menu.count + increase)
                    } else {
                        return Menu(id: menu.id,
                                    name: menu.name,
                                    price: menu.price,
                                    count: menu.count)
                    }
                }
            }
            .take(1) // 1번만 수행함을 의미
            .subscribe(onNext: {
                self.menuObservable.onNext($0)
            })
    }

    func onOrder() {}
}
