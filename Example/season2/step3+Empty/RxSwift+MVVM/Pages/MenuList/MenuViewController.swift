//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

// MARK: - RxMVVM Study

// - 1:15:00 부터 해당 강의 시작 [강의 링크](https://www.youtube.com/watch?v=iHKBNYMWd5I&list=PL03rJBlpwTaBrhux_C8RmtWDI_kZSLvdQ&index=1)

// ★ Observable을 밖에서 컨트롤할 수 없을까? -> Subject를 사용할 수 있다.
// - subject는 Observable을 밖에서도 컨트롤에서 설정해줄 수 있다.(next)값을 만들어 줄 수 있다.
//   - subject의 종류는 총 4가지가 존재한다.
//     - AsyncSubject(completed 시점에 가장 마지막 이벤트를 구독자들에게 전달
//     - PublishSubject(기본값x)
//    - BehaviorSubject(기본값o 구독시 가장 최근값 이후를 전달)
//     - ReplaySubject(구독 시 지금까지의 모든 이벤트를 모두 전달하고 이후 이벤트 방출)

// MARK: - MenuViewController

// - RxCocoa : UIKit에 사용되는 UI들에 Rx를 적용하려할 때 RxCocoa를 사용할 수 있다.
//   - RxCocoa를 사용하면 UI 요소를 subscribe대신 + 순환참조 걱정 없이 bind로 Rx 적용을 시킬 수 있다.

import RxCocoa
import RxSwift
import UIKit

class MenuViewController: UIViewController {
    // MARK: - Property

    let viewModel = MenuListViewModel()
    let disposeBag = DisposeBag()
    private let cellIdentifier = "MenuItemTableViewCell"

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // - [Menu]를 들고있는 Observable, menuObservable
        //   - menuObservable 값이 바뀌면 자동으로 tableView의 값을 변경합니다.
        viewModel.menuObservable
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: cellIdentifier, cellType: MenuItemTableViewCell.self)) { _, item, cell in
                cell.title.text = item.name
                cell.price.text = "\(item.price)"
                cell.count.text = "\(item.count)"

                // MARK: + / - 버튼 눌렀을 때 처리 구현
            }
            .disposed(by: disposeBag)

        // - itemsCount의 방출 값을 itemCountLabel.text로 전달한다.
        viewModel.itemsCount
            .map { "\($0)" }
            .observeOn(MainScheduler.instance)
            .bind(to: itemCountLabel.rx.text)
            .disposed(by: disposeBag)

        // - totalPrice의 값을 원화로 바꿔서 totalPrice에 바로 적용한다.
        // - 아래의 코드 구현으로 별도의 updateUI 이벤트를 호출 할 필요가 없어졌다.
        viewModel.totalPrice
            .map { $0.currencyKR() }
            .observeOn(MainScheduler.instance)
            .bind(to: totalPrice.rx.text)
            .disposed(by: disposeBag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        let identifier = segue.identifier ?? ""
        if identifier == "OrderViewController",
            let orderVC = segue.destination as? OrderViewController {
            // TODO: pass selected menus
        }
    }

    func showAlert(_ title: String, _ message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
    }

    // MARK: - InterfaceBuilder Links

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var itemCountLabel: UILabel!
    @IBOutlet var totalPrice: UILabel!

    // - 메뉴 값 초기화
    @IBAction func onClear() {
        viewModel.clearAllItemSelections()
    }

    // - order버튼 누를때마다 이벤트 수행

    @IBAction func onOrder(_: UIButton) {
        // - 해당 이벤트로, count, price, tableViewData가 연결되며 모두 로직에 맞게 변화된다.
        viewModel.menuObservable.onNext([
            Menu(name: "changed", price: Int.random(in: 100 ... 10000), count: Int.random(in: 0 ... 3)),
            Menu(name: "changed", price: Int.random(in: 100 ... 10000), count: Int.random(in: 0 ... 3)),
            Menu(name: "changed", price: Int.random(in: 100 ... 10000), count: Int.random(in: 0 ... 3)),
        ])

        // TODO: no selection
        // showAlert("Order Fail", "No Orders")
//        performSegue(withIdentifier: "OrderViewController", sender: nil)

        // MARK: Observable 미사용 시

//        self.viewModel.totalPrice += 100
//        self.updateUI()
    }

    /*
     @IBAction ...
     // - 해당 이벤트로, count, price, tableViewData가 연결되며 모두 로직에 맞게 변화된다.
             viewModel.menuObservable.onNext([
                 Menu(name: "changed", price: Int.random(in: 100...10000), count: Int.random(in: 0...3)),
                 Menu(name: "changed", price: Int.random(in: 100...10000), count: Int.random(in: 0...3)),
                 Menu(name: "changed", price: Int.random(in: 100...10000), count: Int.random(in: 0...3))
             ])

             // TODO: no selection
             // showAlert("Order Fail", "No Orders")
     //        performSegue(withIdentifier: "OrderViewController", sender: nil)

             // MARK: Observable 미사용 시
     //        self.viewModel.totalPrice += 100
     //        self.updateUI()

     */

    private func updateUI() {
        itemCountLabel.text = "\(viewModel.itemsCount)"
        // totalPrice.text = viewModel.totalPrice.currencyKR()
    }
}

// - Rx를 쓰면 UITableViewDataSource는 필요 없어집니다.
// extension MenuViewController: UITableViewDataSource {
//    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
//        return viewModel.menuList.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell") as! MenuItemTableViewCell
//
//        let menu = viewModel.menuList[indexPath.row]
//
//
//        return cell
//    }
// }
