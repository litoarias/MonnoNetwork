//
//  URLRequest+Description.swift
//  MonnoNetwork
//
//  Created by MPU8D0000001 on 10/07/2019.
//  Copyright © 2019 MonnoApps. All rights reserved.
//

import Foundation

extension URLRequest {
	public func taskDescription() -> String {
		var result = ""
		result += self.httpMethod?.uppercased() ?? ""
		result += " "
		result += self.url?.absoluteString ?? ""
		result += "\n"
		
		if let headers = allHTTPHeaderFields,
			let headerString = (try? JSONSerialization.data(withJSONObject: headers, options: .prettyPrinted))
				.flatMap({ String(data: $0, encoding: .utf8) }) {
			result += "Headers:\n\(headerString)\n"
		}
		
		if let httpBody = self.httpBody {
			if let dict = (try? JSONSerialization.jsonObject(with: httpBody)) as? [String: Any],
				let jsonString = (try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted))
					.flatMap({ String(data: $0, encoding: .utf8) }) {
				result += "Body:\n\(jsonString)"
			} else {
				result += "Body:\n\(httpBody as NSData)"
			}
		}
		return result
	}
}
