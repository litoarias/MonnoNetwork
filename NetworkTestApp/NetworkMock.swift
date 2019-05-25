//
//  NetworkMock.swift
//  NetworkTestApp
//
//  Created by Lito Arias on 19/05/2019.
//  Copyright © 2019 MonnoApps. All rights reserved.
//

import MonnoNetwork

class NetworkingMockService: Networking {
    
    var baseUrl = ""
    var verbose: Bool = true
    
    func handleResponse<T: Decodable>(for request: URLRequest, completion: @escaping (Result<(T, Data), Error>) -> Void) {
        
        DispatchQueue.main.async {
            
            do {
                var json: [[String: Any]]
                if (request.url?.pathComponents.contains("posts"))! {
                    json = MockedResponses.posts.response as! [[String: Any]]
                } else {
                    json = MockedResponses.posts.response as! [[String: Any]]
                }
                print(json)
                let jsonData = try JSONSerialization.data(withJSONObject:json)
                let items = try JSONDecoder().decode(T.self, from: jsonData)
                completion(.success((items, jsonData)))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
}


