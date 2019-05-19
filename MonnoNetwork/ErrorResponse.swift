//
//  ErrorResponse.swift
//  Database Login
//
//  Created by Kyle Lee on 2/17/19.
//  Copyright © 2019 Kilo Loco. All rights reserved.
//

import Foundation

struct ErrorResponse: Decodable, LocalizedError {
    let reason: String
    
    var errorDescription: String? { return reason }
}
