//
//  ViewController.swift
//  RxSwiftIn4Hours
//
//  Created by iamchiwon on 21/12/2018.
//  Copyright © 2018 n.code. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class ViewController: UIViewController {
    let viewModel = ViewModel()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
    }
    
    // MARK: - IBOutler
    
    @IBOutlet var idField: UITextField!
    @IBOutlet var pwField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var idValidView: UIView!
    @IBOutlet var pwValidView: UIView!
    
    // MARK: - Bind UI
    
    private func bindUI() {
        // id input +--> check valid --> bullet
        //          |
        //          +--> button enable
        //          |
        // pw input +--> check valid --> bullet
        
        /*
         // 1.
         idField.rx.text.orEmpty     // Observable<String>
         .map(checkEmailValid)  // Observable<Bool>
         .distinctUntilChanged() // 같은 값이 나오면 무시한다. // Observable<Bool>
         .subscribe(onNext: { [weak self] h in // 순환 참조
         self?.idValidView.isHidden = h
         })
         .disposed(by: disposeBag)
         
         // 2.
         idField.rx.text.orEmpty
         .map(checkEmailValid)
         .distinctUntilChanged()
         .bind(to: idValidView.rx.isHidden) // 위에서 내려온 값이 isHidden 속성에 그대로 적용
         .disposed(by: disposeBag)
         
         pwField.rx.text.orEmpty
         .map(checkPasswordValid)
         .distinctUntilChanged()
         .subscribe(onNext: { h in
         self.pwValidView.isHidden = h
         })
         .disposed(by: disposeBag)
         */
        
        
        
        
        // ---------------------------------------------------
        
        /*
         
         let ob1: Observable<Bool> = idField.rx.text.orEmpty
         .map(checkEmailValid)
         .distinctUntilChanged()
         
         let ob2: Observable<Bool> = pwField.rx.text.orEmpty
         .map(checkPasswordValid)
         .distinctUntilChanged()
         
         ob1.bind(to: idValidView.rx.isHidden)
         .disposed(by: disposeBag)
         
         ob2.bind(to: pwValidView.rx.isHidden)
         .disposed(by: disposeBag)
         
         Observable.combineLatest(ob1, ob2) { b1, b2 in b1 && b2 }
         .bind(to: loginButton.rx.isEnabled)
         .disposed(by: disposeBag)
         */
        
        /* MVVM에 적용하기 */
        
        // Input 2 : 이메일, 비밀번호 입력
        idField.rx.text.orEmpty.subscribe(onNext: { email in
            self.viewModel.setEmailText(email)
        })
            .disposed(by: disposeBag)
        
        idField.rx.text.orEmpty.bind(to: viewModel.emailText).disposed(by: disposeBag)
        
        pwField.rx.text.orEmpty.subscribe(onNext: { pwd in
            self.viewModel.setPasswordText(pwd)
        })
            .disposed(by: disposeBag)
        
        // Output 2 : 이메일, 비번 체크 결과
        viewModel.isEmailValid
            .bind(to: idValidView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.isPasswordValid
            .bind(to: idValidView.rx.isHidden)
            .disposed(by: disposeBag)
        
        
        // Output 1 : 버튼의 enable 상태
        Observable.combineLatest(viewModel.isEmailValid, viewModel.isPasswordValid) { $0 && $1 }
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
