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
        getJson3()
            .subscribe(onNext: { json in
                DispatchQueue.main.async {
                    self.editView.text = json
                    self.setVisibleWithAnimation(self.activityIndicator, false)
                }
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
