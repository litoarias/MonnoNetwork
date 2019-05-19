//
//  Networking.swift
//  MonnoNetwork
//
//  Created by Lito Arias on 19/05/2019.
//  Copyright © 2019 MonnoApps. All rights reserved.
//

import Foundation

public enum NetworkingError: Error {
    case badUrl
    case badResponse
    case badEncoding
}

public enum HTTPMethod {
    case get
    case post
}

public typealias Headers = [String : String]
public typealias Parameters = [String : Any]

public protocol Networking {
    var baseUrl: String { get set }
    func handleResponse<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void)
    func request<T: Decodable>(method: String, endpoint: String, headers: Headers?, urlParams: [String: Any]?, completion: @escaping (Result<T, Error>) -> Void)
    func request<T: Decodable>(method: String, endpoint: String, headers: Headers?, bodyParams: [String: Any]?, completion: @escaping (Result<T, Error>) -> Void)
    func call<T: Decodable>(path: String, headers: Headers?, params: Parameters?, httpMethod: HTTPMethod, completion: @escaping (Result<T, Error>) -> Void)
}

public extension Networking {
    
    func handleResponse<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                
                guard let unwrappedResponse = response as? HTTPURLResponse else {
                    completion(.failure(NetworkingError.badResponse))
                    return
                }
                
                print(unwrappedResponse.statusCode)
                
                switch unwrappedResponse.statusCode {
                case 200 ..< 300:
                    print("success")
                default:
                    print("failure")
                }
                
                if let unwrappedError = error {
                    completion(.failure(unwrappedError))
                    return
                }
                
                if let unwrappedData = data {
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: unwrappedData, options: [])
                        print(json)
                        
                        if let user = try? JSONDecoder().decode(T.self, from: unwrappedData) {
                            completion(.success(user))
                            
                        } else {
                            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: unwrappedData)
                            completion(.failure(errorResponse))
                        }
                        
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func request<T: Decodable>(method: String, endpoint: String, headers: Headers?, urlParams: [String: Any]?, completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let url = URL(string: baseUrl + endpoint) else {
            completion(.failure(NetworkingError.badUrl))
            return
        }
        
        var request = URLRequest(url: url)
        
        var components = URLComponents()
        
        var queryItems = [URLQueryItem]()
        
        if let params = urlParams {
            for (key, value) in params {
                let queryItem = URLQueryItem(name: key, value: String(describing: value))
                queryItems.append(queryItem)
            }
        }
        
        components.queryItems = queryItems
        
        let queryItemData = components.query?.data(using: .utf8)
        
        request.httpBody = queryItemData
        request.httpMethod = method
        
        if let head = headers {
            for (key, value) in head {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        handleResponse(for: request, completion: completion)
    }
    
    func request<T: Decodable>(method: String, endpoint: String, headers: Headers?, bodyParams: [String: Any]?, completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let url = URL(string: baseUrl + endpoint) else {
            completion(.failure(NetworkingError.badUrl))
            return
        }
        
        var request = URLRequest(url: url)
        
        if let body = bodyParams {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
                request.httpBody = jsonData
            } catch {
                completion(.failure(NetworkingError.badEncoding))
            }
        }
        
        request.httpMethod = method
        
        if let head = headers {
            for (key, value) in head {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        handleResponse(for: request, completion: completion)
    }
    
    func call<T: Decodable>(path: String, headers: Headers?, params: Parameters?, httpMethod: HTTPMethod, completion: @escaping (Result<T, Error>) -> Void) {
        switch httpMethod {
        case .post:
            request(method: "POST", endpoint: path, headers: headers, bodyParams: params, completion: completion)
        case .get:
            request(method: "GET", endpoint: path, headers: headers, urlParams: params, completion: completion)
        }
    }
}


