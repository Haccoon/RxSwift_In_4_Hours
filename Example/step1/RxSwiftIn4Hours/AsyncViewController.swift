//
//  ViewController.swift
//  RxSwiftIn4Hours
//
//  Created by iamchiwon on 21/12/2018.
//  Copyright © 2018 n.code. All rights reserved.
//

import UIKit

class AsyncViewController: UIViewController {
    // MARK: - Field

    var counter: Int = 0
    let IMAGE_URL = "https://picsum.photos/1280/720/?random"

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

    // MARK: - IBAction

    @IBAction func onLoadSync(_ sender: Any) {
        let image = loadImage(from: IMAGE_URL)
        imageView.image = image
    }

    @IBAction func onLoadAsync(_ sender: Any) {
        // TODO: async
        /*
         // 1. BAD
         DispatchQueue.main.async {
            let image = loadImage(from: IMAGE_URL)
            imageView.image = image
         } // 잘못된 것 : 이미지 다운받는 작업과 이미지 뷰에 이미지를 로드하는 작업을 같은 스레드에서 한다
         
         // 2. BAD
         DispatchQueue.global().async {
            let image = loadImage(from: IMAGE_URL)
            imageView.image = image // ERROR! UI는 메인 스레드에서 돌려야하기 때문!
         }
         
         // 3. GOOD
         DispatchQueue.global().async {
            let image = loadImage(from: IMAGE_URL)
            DispatchQueue.main.async {
                imageView.image = image
            }
         }
         */
        loadAsycImage(from: IMAGE_URL) {
            self.imageView.image = $0
        }
    }

    private func loadImage(from imageUrl: String) -> UIImage? {
        guard let url = URL(string: imageUrl) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }

        let image = UIImage(data: data)
        return image
    }
    
    // async 함수는 아래와 같은 형태로 만들 수 없다!
    private func loadAsycImage(from imageUrl: String) -> UIImage? {
        DispatchQueue.global().async {
            let image = self.loadImage(from: imageUrl)
//            return image // ERROR!
        }
        return nil
    }
    
    //  async 함수 방법. 1 콜백으로 전달   2. 델리게이트 이용
    private func loadAsycImage(from imageUrl: String, finished: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let image = self.loadImage(from: imageUrl)
            DispatchQueue.main.async {
                finished(image)
            }
        }
    }
    
    private func loadAsycImage2(from imageUrl: String, finished: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: URL(string: imageUrl)!) { (data, reponse, error) in
            guard let data = data else { return }
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                finished(image)
            }
        }
    }
}
