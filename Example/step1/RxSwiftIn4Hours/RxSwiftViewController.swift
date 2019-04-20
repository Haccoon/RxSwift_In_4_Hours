//
//  RxSwiftViewController.swift
//  RxSwiftIn4Hours
//
//  Created by iamchiwon on 21/12/2018.
//  Copyright © 2018 n.code. All rights reserved.
//

import RxSwift
import UIKit

// 비동기 처리 라이브러리 : PromiseKit, Bolts, RxSwift
// RxSwift가 보다 강력한 점은? => 수 많은 Operator가 존재하기 때문이다!
class RxSwiftViewController: UIViewController {
    // MARK: - Field

    var counter: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.counter += 1
            self.countLabel.text = "\(self.counter)"
        }
    }

    // MARK: - IBOutlet

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var countLabel: UILabel!

    var disposeBag = DisposeBag()
    var disposable: Disposable?
    
    // MARK: - IBAction

    @IBAction func onLoadImage(_ sender: Any) {
        imageView.image = nil

        disposable = rxswiftLoadImage(from: LARGER_IMAGE_URL)
            .observeOn(MainScheduler.instance)
            .subscribe({ result in
                switch result {
                case let .next(image):
                    self.imageView.image = image

                case let .error(err):
                    print(err.localizedDescription)

                case .completed:
                    break
                }
            })
        
        disposeBag.insert(disposable!) // disposeBag에 disposable을 각각 담는다.
        
        rxswiftLoadImage(from: LARGER_IMAGE_URL)
            .observeOn(MainScheduler.instance)
            .subscribe({ result in
                switch result {
                case let .next(image):
                    self.imageView.image = image
                    
                case let .error(err):
                    print(err.localizedDescription)
                    
                case .completed:
                    break
                }
            }).disposed(by: disposeBag) // disposeBag.insert(disposable) 와 똑같다
    }

    @IBAction func onCancel(_ sender: Any) {
        // TODO: cancel image loading
        // 1. disposable 각각 종료 : disposable?.dispose() // 강제 종료
        // 2. disposebag 초기화 : disposeBag = DisposeBag() // 새로 만들면 담겼던 모든 dispose가 종료됨
    }

    // MARK: - RxSwift

    func rxswiftLoadImage(from imageUrl: String) -> Observable<UIImage?> {
        /*
        return Observable.create { seal in
            asyncLoadImage(from: imageUrl) { image in
                seal.onNext(image)
                seal.onCompleted()
            }
            return Disposables.create()
        }
        */
        
        // Observable은 Stream 이다! (onNext를 통해 여러 개의 데이터를 전달할 수 있기 때문)
        return Observable.create { observer in
            let image: UIImage? = nil
            observer.onNext(image) // 스트림의 시작은 첫 번째 데이터가 들어갈 때
            observer.onNext(image)
            observer.onNext(nil)
            observer.onCompleted() // 스트림의 끝 -> 끝나고 나면 죽는다(=disposed).
            // observer.onError(err) // 바로 죽는다(=disposed)

            return Disposables.create()
        }
        
        
        return Observable.create { observer in
            print("이미지 다운로드 하기 전")
            let task = URLSession.shared.dataTask(with: URL(string: imageUrl)!, completionHandler: { (data, reponse, error) in
                print("이미지 다운로드했다")
                if let error = error {
                    print("에러다")
                    observer.onError(error)
                    return
                }
                if let data = data {
                    let image = UIImage(data: data)
                    print("이미지다")
                    observer.onNext(image)
                }
                print("끝났다")
                observer.onCompleted() // 메모리 leak이 날 경우를 대비하여 반드시 completed 호출
            })
            
            print("다운로드 시작")
            task.resume()
            
            return Disposables.create {
                print("다운로드 취소")
                task.cancel() // 강제 종료될 경우에 호출한다.
            }
        }
    }
}
