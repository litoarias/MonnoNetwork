//
//  HTTPURLResponse+Description.swift
//  MonnoNetwork
//
//  Created by MPU8D0000001 on 10/07/2019.
//  Copyright © 2019 MonnoApps. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
	public func taskDescription(_ responseData: Data?) -> String {
		var result = ""
		
		if let urlString = self.url?.absoluteString {
			result += "URL: \(urlString)\n"
		}
		result += "statusCode: \(self.statusCode)\n"
		
		if let headerString = (try? JSONSerialization.data(withJSONObject: self.allHeaderFields, options: .prettyPrinted))
			.flatMap({ String(data: $0, encoding: .utf8) }) {
			result += "Headers:\n\(headerString)\n"
		}
		
		if let contentData = responseData,
			let contentDict = try? JSONSerialization.jsonObject(with: contentData) {
			if let jsonString = (try? JSONSerialization.data(withJSONObject: contentDict, options: .prettyPrinted))
				.flatMap({ String(data: $0, encoding: .utf8) }) {
				result += "\nBody:\n\(jsonString)\n"
			} else {
				// In case we could NOT convert back to JSON, just print the Swift dictionary.
				result += "\nBody:\n\(String(describing: contentDict))\n"
			}
		}
		
		return result
	}
}
