//
//  ViewController.swift
//  RxSwiftIn4Hours
//
//  Created by iamchiwon on 21/12/2018.
//  Copyright © 2018 n.code. All rights reserved.
//

import RxSwift
import UIKit

class ViewController: UITableViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var progressView: UIActivityIndicatorView!
    
    var disposeBag = DisposeBag()
    
    var counter = 0
    
    // 밑에 나오는 예제와는 달리 런타임에 정해지는 데이터들을 스트림에 넣어서 처리하려면 어떻게 해야할까?!
    // 스트림에 흘러 가야할 데이터를 스트림(Observable) 밖에서 정해줘야 할 때 쓰는 것: Subject이다!
    let subject = PublishSubject<Int>() // Observable 이면서 Observer
    
    // 기본적인 observblae은 cold observblae // subscribe를 해야 동작하는 것들
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Subject 사용하기 */
        
        // Observer
        subject.onNext(1)
        
        // Observable
        subject
            .subscribe(onNext: { i in
                print(i)
            })
            .disposed(by: disposeBag)
        
        subject
            .skip(5)
            .subscribe(onNext: { i in
                print(i * 100)
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func exJust1() {
        
        /*
         let observable = Observable<String>.create { observer in
         observer.onNext("Hello World")
         observer.onCompleted()
         return Disposables.create()
         }
         
         let disposable = observable.subscribe { event in
         switch event {
         case .next(let text):
         print(text)
         case .completed:
         break
         case .error(let _):
         break
         }
         }
         */
        
        // 위와 동일함
        // SUGAR = operator
        //        Observable.just("Hello World") // Observable<String>
        //            .subscribe(onNext: { str in
        //                print(str)
        //            }, onCompleted: {
        //                print("completed")
        //            })
        //            .disposed(by: disposeBag)
        //
        //        _ = Observable.just("Hello World").subscribe(onNext: { print($0) })
        
        counter += 1
        subject.onNext(counter) // hot observable // subscribe 하지 않아도 데이터를 버리면서 전달
    }
    
    @IBAction func exJust2() {
        Observable.just(["Hello", "World"]) // Observable<[String]>
            .subscribe(onNext: { arr in
                print(arr)
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func exFrom1() {
        Observable.from(["RxSwift", "In", "4", "Hours"]) // Observable<String>
            .subscribe(onNext: { str in
                print(str)
            }, onCompleted: {
                print("completed")
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func exMap1() {
        Observable.just("Hello")  // Observable<String>
            .map { str in "\(str) RxSwift" } // Observable<String>
            .subscribe(onNext: { str in
                print(str)
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func exMap2() {
        Observable.from(["with", "곰튀김"]) // Observable<String>
            .map { $0.count } // Observable<Int>
            .subscribe(onNext: { str in
                print(str)
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func exFilter() {
        Observable.from([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) // Observable<Int>
            .filter { $0 % 2 == 0 } // $0.isMultiple(of: 2)
            .subscribe(onNext: { n in
                print(n)
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func exMap3() {
        // error 다운로드 하는 작업을 메인 스레드에서 처리하고 있기 때문에 다운로드 중에는 스크롤 안먹음
        Observable.just("800x600")
            .map { $0.replacingOccurrences(of: "x", with: "/") }
            .map { "https://picsum.photos/\($0)/?random" } // Observable<String>
            .map { URL(string: $0) } // Observable<URL?>
            .filter { $0 != nil } // Observable<URL?>
            .map { $0! } // Observable<URL>
            .map { try Data(contentsOf: $0) } // Observable<Data>
            .map { UIImage(data: $0) } // Observable<UIImage?>
            .subscribe(onNext: { image in
                self.imageView.image = image
            })
            .disposed(by: disposeBag)
        
        // 1. observeOn 사용하기
        Observable.just("800x600")
            .map { $0.replacingOccurrences(of: "x", with: "/") }
            .map { "https://picsum.photos/\($0)/?random" } // Observable<String>
            .map { URL(string: $0) } // Observable<URL?>
            .filter { $0 != nil } // Observable<URL?>
            .map { $0! } // Observable<URL>
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .default)) // 스레드를 변경한다!
            .map { try Data(contentsOf: $0) } // Observable<Data>
            .map { UIImage(data: $0) } // Observable<UIImage?>
            .observeOn(MainScheduler.instance) // 스레드를 변경한다!
            .subscribe(onNext: { image in
                self.imageView.image = image
            })
            .disposed(by: disposeBag)
        
        // 2. subscribeOn 사용하기 : 좀더 효율적이다.. (메인 스레드의 작업을 덜어준다.)
        Observable.just("800x600")
            .map { $0.replacingOccurrences(of: "x", with: "/") }
            .map { "https://picsum.photos/\($0)/?random" } // Observable<String>
            .map { URL(string: $0) } // Observable<URL?>
            .filter { $0 != nil } // Observable<URL?>
            .map { $0! } // Observable<URL>
            .map { try Data(contentsOf: $0) } // Observable<Data>
            .map { UIImage(data: $0) } // Observable<UIImage?>
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default)) // 처음부터 해당 스레드에서 작업한다.
            .observeOn(MainScheduler.instance) // 화면을 바꾸는 시점부터 메인 스레드에서 동작하게
            .subscribe(onNext: { image in
                self.imageView.image = image
            })
            .disposed(by: disposeBag)
    }
}
