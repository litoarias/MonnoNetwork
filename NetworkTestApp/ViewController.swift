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
        return self.mocks ? NetworkingMockService() : NetworkingService(baseUrl: "http://argo.cdragota.lab.cloudioo.net/api_contents")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func dataRequest() {

        let preferredLanguage = NSLocale.preferredLanguages[0]
        
        networkingService.call(path: "/get/wallpapers_categories", headers: nil, params: ["lang":preferredLanguage], httpMethod: .get) { (result: Result<[Tag], Error>) in
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

