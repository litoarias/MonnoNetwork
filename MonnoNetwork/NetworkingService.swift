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
    case unknown(Data)
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
public typealias Parameters = [String: Any]

/// <#Description#>
public protocol Networking {
    
    var verbose: Bool { get set }
    var baseUrl: String { get set }
    func handleResponse<T: Decodable>(for request: URLRequest, completion: @escaping (Result<(object: T, unwrapped: Data), Error>) -> Void)
    func request<T: Decodable>(method: String, path: String, headers: Headers?, urlParams: Parameters?, completion: @escaping (Result<(object: T, unwrapped: Data), Error>) -> Void)
    func request<T: Decodable>(method: String, path: String, headers: Headers?, bodyParams: Parameters?, completion: @escaping (Result<(object: T, unwrapped: Data), Error>) -> Void)
    func call<T: Decodable>(path: String, headers: Headers?, params: Parameters?, httpMethod: HTTPMethod, completion: @escaping (Result<(object: T, unwrapped: Data), Error>) -> Void)
}

public extension Networking {
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    func handleResponse<T: Decodable>(for request: URLRequest, completion: @escaping (Result<(object: T, unwrapped: Data), Error>) -> Void) {
        let session = URLSession.shared
        
        #if DEBUG
        print("REQUEST:\n")
        dump(request)
        print("-----------------")
        #endif

        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                #if DEBUG
                print("DATA:\n")
                dump(String(data: data ?? Data(), encoding: .utf8))
                print("-----------------")
                print("RESPONSE:\n")
                dump(response)
                print("-----------------")
                print("ERROR: -----------------")
                dump(error)
                print("-----------------")
                #endif

//                guard let unwrappedResponse = response as? HTTPURLResponse else {
//                    completion(.failure(NetworkingError.badResponse))
//                    return
//                }
                if let unwrappedError = error {
                    completion(.failure(unwrappedError))
                    return
                }
                if let unwrappedData = data {
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let object = try decoder.decode(T.self, from: unwrappedData)
                        completion(.success((object, unwrappedData)))
                    } catch {
                        completion(.failure(NetworkingError.unknown(unwrappedData)))
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
    ///   - path: <#endpoint description#>
    ///   - headers: <#headers description#>
    ///   - urlParams: <#urlParams description#>
    ///   - completion: <#completion description#>
    func request<T: Decodable>(method: String, path: String, headers: Headers?, urlParams: Parameters?, completion: @escaping (Result<(object: T, unwrapped: Data), Error>) -> Void) {
        guard let url = URL(string: baseUrl) else {
            completion(.failure(NetworkingError.badUrl))
            return
        }
        var components = URLComponents()
        components.scheme = url.scheme
        components.host = url.host
        components.path = path
       
        var queryItems = [URLQueryItem]()
        
        if let params = urlParams {
            for (key, value) in params {
                let queryItem = URLQueryItem(name: key, value: value as? String)
                queryItems.append(queryItem)
            }
        }
        
        components.queryItems = queryItems
        
        guard let urlQuery = components.url else {
            completion(.failure(NetworkingError.badUrl))
            return
        }
        var request = URLRequest(url: urlQuery)
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
    func request<T: Decodable>(method: String, path: String, headers: Headers?, bodyParams: Parameters?, completion: @escaping (Result<(object: T, unwrapped: Data), Error>) -> Void) {
        guard let url = URL(string: baseUrl + path) else {
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
    func call<T: Decodable>(path: String, headers: Headers?, params: Parameters?, httpMethod: HTTPMethod, completion: @escaping (Result<(object: T, unwrapped: Data), Error>) -> Void) {
        switch httpMethod {
        case .post:
            request(method: "POST", path: path, headers: headers, bodyParams: params, completion: completion)
        case .get:
            request(method: "GET", path: path, headers: headers, urlParams: params, completion: completion)
        }
    }
}


