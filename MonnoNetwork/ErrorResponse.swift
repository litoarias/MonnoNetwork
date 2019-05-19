//  ErrorResponse.swift
//  MonnoNetwork
//
//  Created by Lito Arias on 19/05/2019.
//  Copyright © 2019 MonnoApps. All rights reserved.
//

import Foundation

struct ErrorResponse: Decodable, LocalizedError {
    let reason: String
    
    var errorDescription: String? { return reason }
}
