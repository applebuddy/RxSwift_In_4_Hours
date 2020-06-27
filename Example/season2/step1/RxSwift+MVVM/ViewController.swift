//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class 나중에생기는스트링데이터 {
    let _job: (@escaping (String) -> Void) -> Void

    init(_ job: @escaping (@escaping (String) -> Void) -> Void) {
        _job = job
    }

    func 오겠지(_ f: @escaping (String) -> Void) {
        DispatchQueue.global().async {
            self._job(f)
        }
    }
}

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }

    /*
     func getJson() -> String {
         DispatchQueue.main.async {
             guard let url = URL(string: MEMBER_LIST_URL),
                 let data = try? Data(contentsOf: url) else { return }
             let json = String(data: data, encoding: .utf8)
             return json // 백그라운드 클로져 내에서 getJson() 메서드의 String 반환을 어떻게 시켜야 할까?
         }
     }
     */

    func getJson(_ onCompleted: @escaping (String) -> Void) {
        DispatchQueue.main.async {
            guard let url = URL(string: MEMBER_LIST_URL),
                let data = try? Data(contentsOf: url),
                let json = String(data: data, encoding: .utf8) else { return }

            onCompleted(json)
        }
    }

    func getJson2() -> 나중에생기는스트링데이터 {
        return 나중에생기는스트링데이터 { f in
            guard let url = URL(string: MEMBER_LIST_URL),
                let data = try? Data(contentsOf: url),
                let json = String(data: data, encoding: .utf8) else { return }

            f(json)
        }
    }

    // - Observable의 사용 예시)
    // 위의 getJson2 메서드와 형태가 유사하다.
    func getJson3() -> Observable<String> {
        return Observable.create { f in
            guard let url = URL(string: MEMBER_LIST_URL),
                let data = try? Data(contentsOf: url),
                let json = String(data: data, encoding: .utf8) else { return Disposables.create() }

            f.onNext(json)
            return Disposables.create()
        }
    }

    // MARK: SYNC

    var disposable: Disposable?

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)

        // MARK: Async Operation

        /*
         self.getJson { [weak self] json in
             self?.editView.text = json
         }
         */

        // - Observable의 의미 : "나중에 데이터 줄게!"
        //   - ConcurrentDispatchQueueScheduler Operator를 사용하면 아래의 첫 작업 부터 DispatchQueue와 같은 효과를 얻는다.
        //   - observeOn(MainScheduler.instance 를 사용하면 메인스레드에서 동작하도록 할 수 있다.
        // .  - subscribeOn : 동작 간 특정 스레드를 지정해서 동작한다.
        disposable = getJson3()
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance) // 메인스레드(MainScheduler.instance)에서 동작하도록 한다.
            .subscribe(onNext: { json in
                self.editView.text = json
                self.setVisibleWithAnimation(self.activityIndicator, false)
            })

        // MARK: - Observable과 비슷한 원리의 Async 동작 예시)

        /*
         getJson2()
             .오겠지 { [weak self] json in
                 DispatchQueue.main.async {
                     self?.editView.text = json
                     self?.setVisibleWithAnimation(self?.activityIndicator, false)
                 }
             }
         */

        // MARK: Sync Operation

        /*
         let url = URL(string: MEMBER_LIST_URL)!
         let data = try! Data(contentsOf: url)
         let json = String(data: data, encoding: .utf8)
         self.editView.text = json
         */

//        self.setVisibleWithAnimation(self.activityIndicator, false)
    }
}
