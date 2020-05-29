//
//  Parameters+JSONObject.swift
//  MonnoNetwork
//
//  Created by Hipolito Arias on 25/08/2019.
//  Copyright © 2019 MonnoApps. All rights reserved.
//

import Foundation

extension Encodable {
    
    public func jsonObject() -> [String: Any]? {
        do {
            let jsonData = try JSONEncoder().encode(self)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else { return nil }
            guard let data = jsonString.data(using: .utf8) else { return nil }
            let jsonParams = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            return jsonParams
        } catch {
            debugPrint(error)
            return nil
        }
    }
}

