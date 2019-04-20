//
//  ViewModel.swift
//  RxSwiftIn4Hours
//
//  Created by Hakyung Kim on 20/04/2019.
//  Copyright © 2019 n.code. All rights reserved.
//

import Foundation
import RxSwift

// 뷰에서 비즈니스 로직 부분은 ViewModel로 뺀다
// 선언형 프로그래밍
class ViewModel {
    // View 와 ViewModel의 매개체 역할을 *Subject*가 하고 있다!
    
    
    // MARK: - Input
    // 인풋 텍스트 값을 갖는 것도 뷰 모델에 넣을 수 있따
    let emailText = BehaviorSubject<String>(value: "")
    
    
    
    // MARK: - Output
    
    //    let isEmailValid = PublishSubject<Bool>()
    //    let isPasswordValid = PublishSubject<Bool>()
    
    // 기본 값이 필요하므로 BehaviorSubject로 변경 : 이유는 Button 처음의 enabled 상태 때문에
    
    let isEmailValid = BehaviorSubject<Bool>(value: false)
    let isPasswordValid = BehaviorSubject<Bool>(value: false)
    
    
    
    init() {
        
        // 요런식으로 가능
        _ = emailText
            .distinctUntilChanged()
            .map(checkEmailValid)
            .bind(to: isEmailValid)
    }
    
    func setEmailText(_ email: String) {
        let isValid = checkEmailValid(email)
        isEmailValid.onNext(isValid)
    }
    
    func setPasswordText(_ pwd: String) {
        let isValid = checkPasswordValid(pwd)
        isPasswordValid.onNext(isValid)
    }
    
    // MARK: - Logic
    // 내가 핸들링하는 부분은 밑에 부분만이기 때문에 버그가 날 확률이 적어진다
    private func checkEmailValid(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }
    
    private func checkPasswordValid(_ password: String) -> Bool {
        return password.count > 5
    }
}
