//
//  Network.swift
//  NetworkTestApp
//
//  Created by Lito Arias on 19/05/2019.
//  Copyright © 2019 MonnoApps. All rights reserved.
//

import MonnoNetwork

public class NetworkingService: Networking {
    
    public var baseUrl = ""
    
    public init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
}
