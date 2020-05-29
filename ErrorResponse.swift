//  ErrorResponse.swift
//  MonnoNetwork
//
//  Created by Lito Arias on 19/05/2019.
//  Copyright © 2019 MonnoApps. All rights reserved.
//

import Foundation

public struct ErrorResponse: Decodable, LocalizedError {
    public let reason: String
    public var errorDescription: String? { return reason }
}
