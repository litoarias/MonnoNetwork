//
//  Networking.swift
//  MonnoNetwork
//
//  Created by Lito Arias on 19/05/2019.
//  Copyright © 2019 MonnoApps. All rights reserved.
//

import Foundation

/// <#Description#>
///
/// - badUrl: <#badUrl description#>
/// - badResponse: <#badResponse description#>
/// - badEncoding: <#badEncoding description#>
public enum NetworkingError: Error {
    case badUrl
    case badResponse
    case badEncoding
}

/// <#Description#>
///
/// - get: <#get description#>
/// - post: <#post description#>
public enum HTTPMethod {
    case get
    case post
}


/// <#Description#>
public typealias Headers = [String : String]
public typealias Parameters = [String: String]


/// <#Description#>
public protocol Networking {
    var baseUrl: String { get set }
    func handleResponse<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void)
    func request<T: Decodable>(method: String, endpoint: String, headers: Headers?, urlParams: Parameters?, completion: @escaping (Result<T, Error>) -> Void)
    func request<T: Decodable>(method: String, endpoint: String, headers: Headers?, bodyParams: Parameters?, completion: @escaping (Result<T, Error>) -> Void)
    func call<T: Decodable>(path: String, headers: Headers?, params: Parameters?, httpMethod: HTTPMethod, completion: @escaping (Result<T, Error>) -> Void)
}

public extension Networking {
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    func handleResponse<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let unwrappedResponse = response as? HTTPURLResponse else {
                    completion(.failure(NetworkingError.badResponse))
                    return
                }
                #if DEBUG
                print(unwrappedResponse.statusCode)
                switch unwrappedResponse.statusCode {
                case 200 ..< 300:
                    print("success")
                default:
                    print("failure")
                }
                #endif
                if let unwrappedError = error {
                    completion(.failure(unwrappedError))
                    return
                }
                if let unwrappedData = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: unwrappedData, options: [])
                        #if DEBUG
                        print(json)
                        #endif
                        let object = try JSONDecoder().decode(T.self, from: unwrappedData)
                        completion(.success(object))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        }
        task.resume()
    }
    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - method: <#method description#>
    ///   - endpoint: <#endpoint description#>
    ///   - headers: <#headers description#>
    ///   - urlParams: <#urlParams description#>
    ///   - completion: <#completion description#>
    func request<T: Decodable>(method: String, endpoint: String, headers: Headers?, urlParams: Parameters?, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: baseUrl + endpoint) else {
            completion(.failure(NetworkingError.badUrl))
            return
        }
        var request = URLRequest(url: url)
        var components = URLComponents()
        var queryItems = [URLQueryItem]()
        if let params = urlParams {
            for (key, value) in params {
                let queryItem = URLQueryItem(name: key, value: value)
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
    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - method: <#method description#>
    ///   - endpoint: <#endpoint description#>
    ///   - headers: <#headers description#>
    ///   - bodyParams: <#bodyParams description#>
    ///   - completion: <#completion description#>
    func request<T: Decodable>(method: String, endpoint: String, headers: Headers?, bodyParams: Parameters?, completion: @escaping (Result<T, Error>) -> Void) {
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
    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - path: <#path description#>
    ///   - headers: <#headers description#>
    ///   - params: <#params description#>
    ///   - httpMethod: <#httpMethod description#>
    ///   - completion: <#completion description#>
    func call<T: Decodable>(path: String, headers: Headers?, params: Parameters?, httpMethod: HTTPMethod, completion: @escaping (Result<T, Error>) -> Void) {
        switch httpMethod {
        case .post:
            request(method: "POST", endpoint: path, headers: headers, bodyParams: params, completion: completion)
        case .get:
            request(method: "GET", endpoint: path, headers: headers, urlParams: params, completion: completion)
        }
    }
}


