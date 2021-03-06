//
//  Networking.swift
//  MonnoNetwork
//
//  Created by Lito Arias on 19/05/2019.
//  Copyright © 2019 MonnoApps. All rights reserved.
//

import Foundation

/// 
///
/// - badUrl: <#badUrl description#>
/// - badResponse: <#badResponse description#>
/// - badEncoding: <#badEncoding description#>
public enum NetworkingError: Error {
    case badUrl
    case badResponse
    case badEncoding
    case serializationError(SerializationError)
    case serverError(Data, HTTPURLResponse?)
    case unknown(Data)
    case urlRequestIsNil
    case urlSessionIsNil
}

public enum SerializationError: Error {
    case nilData
    case emptyData
    case cannotSerialize
}

/// <#Description#>
///
/// - get: <#get description#>
/// - post: <#post description#>
public enum HTTPMethod {
    case get
    case post
    case patch
    case postMultipart
    case patchMultipart
}

/// <#Description#>
public typealias Headers = [String: String]
public typealias Parameters = [String: Any]

/// <#Description#>
public protocol Networking: class {
    var request: URLRequest? { get set }
    var session: URLSession? { get set }
    var baseUrl: String { get set }
    func handleResponse<T: Decodable>(for request: URLRequest, completion: @escaping (Result<(object: T?, unwrapped: Data), Error>) -> Void)
    func handleResponseMultiTask<T: Decodable>(for request: URLRequest, data: Data, completion: @escaping (Result<(object: T?, unwrapped: Data), Error>) -> Void)
    func request<T: Decodable>(method: String, path: String, headers: Headers?, urlParams: Parameters?, completion: @escaping (Result<(object: T?, unwrapped: Data), Error>) -> Void)
    func request<T: Decodable>(method: String, path: String, headers: Headers?, bodyParams: Parameters?, completion: @escaping (Result<(object: T?, unwrapped: Data), Error>) -> Void)
    
    func request<T: Decodable>(image: UIImage, method: String, path: String, headers: Headers?, multipart: Parameters?, completion: @escaping (Result<(object: T?, unwrapped: Data), Error>) -> Void)
    
    func call<T: Decodable>(path: String, headers: Headers?, params: Parameters?, httpMethod: HTTPMethod, completion: @escaping (Result<(object: T?, unwrapped: Data), Error>) -> Void, image: UIImage?)
}

public extension Networking {
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    func handleResponse<T: Decodable>(for request: URLRequest, completion: @escaping (Result<(object: T?, unwrapped: Data), Error>) -> Void) {
        
        guard let urlsession = session else {
            completion(.failure(NetworkingError.urlSessionIsNil))
            return
        }
        
        let task = urlsession.dataTask(with: request) { (data, taskResponse, taskError) in
            DispatchQueue.main.async {
                #if DEBUG
                debugPrint("======================== BEGIN REQUEST ========================")
                debugPrint(request.taskDescription())
                debugPrint("========================= END REQUEST =========================")
                #endif
                
                guard taskError == nil else {
                    completion(.failure(taskError!))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NetworkingError.serializationError(.nilData)))
                    return
                }
                
                guard let response = taskResponse as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    guard let urlResponse = taskResponse as? HTTPURLResponse else {
                        completion(.failure(NetworkingError.serverError(data, nil)))
                        return
                    }
                    completion(.failure(NetworkingError.serverError(data, urlResponse)))
                    return
                }
                
                debugPrint("======================== BEGIN RESPONSE ========================")
                debugPrint(response.taskDescription(data))
                debugPrint("========================= END RESPONSE =========================")
                
                //    guard let mime = response.mimeType, mime == "application/json" else {
                //        print("Wrong MIME type!")
                //        return
                //    }
                
                do {
                    let object = try JSONDecoder().decode(T.self, from: data)
                    completion(.success((object, data)))
                } catch {
                    completion(.success((nil, data)))
                }
                
            }
        }
        task.resume()
    }
    
    func handleResponseMultiTask<T: Decodable>(for request: URLRequest, data: Data, completion: @escaping (Result<(object: T?, unwrapped: Data), Error>) -> Void) {
        
        guard let urlsession = session else {
            completion(.failure(NetworkingError.urlSessionIsNil))
            return
        }
        let task = urlsession.uploadTask(with: request, from: data, completionHandler: { (data, taskResponse, taskError) in
            DispatchQueue.main.async {
                #if DEBUG
                debugPrint("======================== BEGIN REQUEST ========================")
                debugPrint(request.taskDescription())
                debugPrint("========================= END REQUEST =========================")
                #endif
                
                guard taskError == nil else {
                    completion(.failure(taskError!))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NetworkingError.serializationError(.nilData)))
                    return
                }
                
                guard let response = taskResponse as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    guard let urlResponse = taskResponse as? HTTPURLResponse else {
                        completion(.failure(NetworkingError.serverError(data, nil)))
                        return
                    }
                    completion(.failure(NetworkingError.serverError(data, urlResponse)))
                    return
                }
                
                debugPrint("======================== BEGIN RESPONSE ========================")
                debugPrint(response.taskDescription(data))
                debugPrint("========================= END RESPONSE =========================")
                
                do {
                    let object = try JSONDecoder().decode(T.self, from: data)
                    completion(.success((object, data)))
                } catch {
                    completion(.success((nil, data)))
                }
                
            }
        })
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
    func request<T: Decodable>(method: String, path: String, headers: Headers?, urlParams: Parameters?, completion: @escaping (Result<(object: T?, unwrapped: Data), Error>) -> Void) {
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
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let urlQuery = components.url else {
            completion(.failure(NetworkingError.badUrl))
            return
        }
        
        request = URLRequest(url: urlQuery)
        
        guard var secureRequest = request else {
            completion(.failure(NetworkingError.urlRequestIsNil))
            return
        }
        
        secureRequest.httpMethod = method
        if let head = headers {
            for (key, value) in head {
                secureRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        handleResponse(for: secureRequest, completion: completion)
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - method: <#method description#>
    ///   - endpoint: <#endpoint description#>
    ///   - headers: <#headers description#>
    ///   - bodyParams: <#bodyParams description#>
    ///   - completion: <#completion description#>
    func request<T: Decodable>(method: String, path: String, headers: Headers?, bodyParams: Parameters?, completion: @escaping (Result<(object: T?, unwrapped: Data), Error>) -> Void) {
        guard let url = URL(string: baseUrl + path) else {
            completion(.failure(NetworkingError.badUrl))
            return
        }
        request = URLRequest(url: url)
        
        guard var secureRequest = request else {
            completion(.failure(NetworkingError.urlRequestIsNil))
            return
        }
        
        if let body = bodyParams {
            if let head = headers, head.values.contains("application/x-www-form-urlencoded") {
                secureRequest.httpBody = body.percentEscaped().data(using: .utf8)
            } else {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
                    secureRequest.httpBody = jsonData
                } catch {
                    completion(.failure(NetworkingError.badEncoding))
                }
            }
        }
        secureRequest.httpMethod = method
        if let head = headers {
            for (key, value) in head {
                secureRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        handleResponse(for: secureRequest, completion: completion)
    }
    
    /// 
    ///
    /// - Parameters:
    ///   - method: <#method description#>
    ///   - endpoint: <#endpoint description#>
    ///   - headers: <#headers description#>
    ///   - bodyParams: <#bodyParams description#>
    ///   - completion: <#completion description#>
    func request<T: Decodable>(image: UIImage, method: String, path: String, headers: Headers?, multipart: Parameters?, completion: @escaping (Result<(object: T?, unwrapped: Data), Error>) -> Void) {
        guard let url = URL(string: baseUrl + path) else {
            completion(.failure(NetworkingError.badUrl))
            return
        }
        request = URLRequest(url: url)
        
        guard var secureRequest = request else {
            completion(.failure(NetworkingError.urlRequestIsNil))
            return
        }
        
        secureRequest.httpMethod = method
        
        if let head = headers {
            for (key, value) in head {
                secureRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        let filename = "avatar.png"

        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString

        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        secureRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()
        
        // Add the image data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"photo\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)

        // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
        // According to the HTTP 1.1 specification https://tools.ietf.org/html/rfc7230
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        handleResponseMultiTask(for: secureRequest, data: data, completion: completion)

    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - path: <#path description#>
    ///   - headers: <#headers description#>
    ///   - params: <#params description#>
    ///   - httpMethod: <#httpMethod description#>
    ///   - completion: <#completion description#>
    func call<T: Decodable>(path: String, headers: Headers?, params: Parameters?, httpMethod: HTTPMethod, completion: @escaping (Result<(object: T?, unwrapped: Data), Error>) -> Void, image: UIImage? = nil) {
        switch httpMethod {
        case .post:
            request(method: "POST", path: path, headers: headers, bodyParams: params, completion: completion)
        case .get:
            request(method: "GET", path: path, headers: headers, urlParams: params, completion: completion)
        case .patch:
            request(method: "PATCH", path: path, headers: headers, bodyParams: params, completion: completion)
        case .postMultipart:
            request(image: image!, method: "POST", path: path, headers: headers, multipart: params, completion: completion)
        
        case .patchMultipart:
            request(image: image!, method: "PATCH", path: path, headers: headers, multipart: params, completion: completion)
        }
    }
}

public enum MultipartFormDataEncodingError: Error {
    case characterSetName
    case name(String)
    case value(String, name: String)
}
