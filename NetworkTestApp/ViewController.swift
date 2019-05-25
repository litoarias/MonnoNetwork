//
//  ViewController.swift
//  NetworkTestApp
//
//  Created by Lito Arias on 19/05/2019.
//  Copyright © 2019 MonnoApps. All rights reserved.
//

import UIKit
import MonnoNetwork

class ViewController: UIViewController {
   
    let mocks: Bool = false
    var networkingService: Networking {
//        return self.mocks ? NetworkingMockService() : NetworkingService(baseUrl: "https://jsonplaceholder.typicode.com/posts")
        return self.mocks ? NetworkingMockService() : NetworkingService(baseUrl: "http://argo.cdragota.lab.cloudioo.net")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func dataRequest() {

        let preferredLanguage = NSLocale.preferredLanguages[0]
        
        
//        networkingService.call(path: "/api_contents/get/wallpapers_categories", headers: nil, params: ["lang":preferredLanguage], httpMethod: .get) { (result: Result<[Tag], Error>) in
//            switch result {
//            case .success(let post):
//                print(post)
//                let alert = UIAlertController(title: "SUCCESS", message: "\(String(describing: post))", preferredStyle: .alert)
//
//                let act = UIAlertAction(title: "Yes", style: .default, handler: { _ in
//                    alert.dismiss(animated: true, completion: nil)
//                })
//                alert.addAction(act)
//                self.present(alert, animated: true)
//            case .failure(let error):
//                print(error)
//                let alert = UIAlertController(title: "ERROR", message: "\(String(describing: error))", preferredStyle: .alert)
//
//                let act = UIAlertAction(title: "Yes", style: .default, handler: { _ in
//                    alert.dismiss(animated: true, completion: nil)
//                })
//                alert.addAction(act)
//                self.present(alert, animated: true)
//            }
//        }
        
          networkingService.call(path: "/api_contents/get/wallpapers_categories", headers: nil, params: ["lang":preferredLanguage], httpMethod: .get) { (result :Result<(object: [Tag], unwrapped: Data), Error>) in
        
            switch result {
            case .success(let tuple):
                let obj = tuple.object
                let data = String(data: tuple.unwrapped, encoding: .utf8)
                let alert = UIAlertController(title: "SUCCESS", message: "OBJECT: \(obj)\nDATA: \(data ?? "")", preferredStyle: .alert)
                
                let act = UIAlertAction(title: "Yes", style: .default, handler: { _ in
                    alert.dismiss(animated: true, completion: nil)
                })
                alert.addAction(act)
                self.present(alert, animated: true)
            case .failure(let error):
                print(error)
                var strError: String = ""
                switch error as? NetworkingError {
                case .unknown(let data)?:
                    print(data)
                    strError = String(data: data, encoding: .utf8)!
                default:
                    print(error)
                    strError = String(describing: error)
                    break
                }
                let alert = UIAlertController(title: "ERROR", message: "\(String(describing: strError))", preferredStyle: .alert)
                
                let act = UIAlertAction(title: "Yes", style: .default, handler: { _ in
                    alert.dismiss(animated: true, completion: nil)
                })
                alert.addAction(act)
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func testRequest(_ sender: UIButton) {
        dataRequest()
    }
}

