//
//  ViewController.swift
//  RxSwiftGetStarted
//
//  Created by luojie on 2017/2/18.
//  Copyright © 2017年 LuoJie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet private weak var usernameTextfield: UITextField!
    @IBOutlet private weak var usernameValidLabel: UILabel!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var passwordValidLabel: UILabel!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var loginAlertLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }
    
    private func setupRx() {
        
        // 验证用户输入是否有效
        let usernameIsValid: Observable<Bool> = usernameTextfield.rx.text.orEmpty
            .map { newUsername in newUsername.characters.count > 5 }
        
        let passwordIsValid: Observable<Bool> = passwordTextField.rx.text.orEmpty
            .map { newPassword in newPassword.characters.count > 5 }
        
        usernameIsValid
            .bindTo(usernameValidLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        passwordIsValid
            .bindTo(passwordValidLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 验证是否满足登录条件
        let isLoginEnable: Observable<Bool> = Observable.combineLatest(usernameIsValid, passwordIsValid) {
            usernameIsValid, passwordIsValid in usernameIsValid && passwordIsValid
        }
        
        isLoginEnable
            .bindTo(loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 发起登录操作
        let usernameAndPassword: Observable<(String, String)> = Observable.combineLatest(
            usernameTextfield.rx.text.orEmpty,
            passwordTextField.rx.text.orEmpty
        ) { (username, password) in (username, password) }
        
        let rxUser: Observable<User?> = loginButton.rx.tap
            .withLatestFrom(usernameAndPassword)
            .do(onNext: { [weak self] _ in
                self?.loginAlertLabel.text = "正在登录,请稍等..."
                self?.view.endEditing(true)
            })
            .flatMapLatest(GithubApi.login)
        
        // 显示登录结果
        rxUser
            .observeOn(MainScheduler.instance)
            .map { user in
                user == nil ? "登录失败，请稍后重试" : "\(user!.nickname) 您已成功登录"
            }
            .bindTo(loginAlertLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
}

enum GithubApi {
    
    // 封装网络请求的方法
    public static func login(username: String, password: String) -> Observable<User?> {
        guard
            let baseURL = URL(string: "https://api.github.com"),
            let url = URL(string: "login?username=\(username)&password=\(password)", relativeTo: baseURL)
            else {
                return Observable.just(nil)
        }
        
        return URLSession.shared.rx.json(url: url)
            .catchErrorJustReturn(["id": "10000", "nickname": "luojie"]) // 由于此接口不存在，所以出错就直接返回演示数据
            .map(User.init) // 解析 json
    }
}

// 用户模型
struct User {
    let id: String
    let nickname: String
    
    // 解析 json
    init?(json: Any) {
        guard
            let dictionary = json as? [String: Any],
            let id = dictionary["id"] as? String,
            let nickname = dictionary["nickname"] as? String
            else {
            return nil
        }
        
        self.id = id
        self.nickname = nickname
    }
}


