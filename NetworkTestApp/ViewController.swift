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
   
    let mocks: Bool = true
    var networkingService: Networking {
        return self.mocks ? NetworkingMockService() : NetworkingService(baseUrl: "https://jsonplaceholder.typicode.com")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func dataRequest() {
        networkingService.call(path: "/posts", headers: nil, params: nil, httpMethod: .get) { (result: Result<[Post], Error>) in
            switch result {
            case .success(let post):
                print(post)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func testRequest(_ sender: UIButton) {
        dataRequest()
    }
}

