//
//  Network.swift
//  NetworkTestApp
//
//  Created by Lito Arias on 19/05/2019.
//  Copyright © 2019 MonnoApps. All rights reserved.
//

import MonnoNetwork
import Foundation

public class NetworkingService: NSObject, Networking, URLSessionDelegate {
    
    public var session: URLSession?
    
    public var baseUrl = ""
    
    public init(baseUrl: String) {
        super.init()
        self.baseUrl = baseUrl
        self.session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
}


