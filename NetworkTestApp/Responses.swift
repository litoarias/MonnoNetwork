//
//  Responses.swift
//  NetworkTestApp
//
//  Created by Lito Arias on 19/05/2019.
//  Copyright © 2019 MonnoApps. All rights reserved.
//

import MonnoNetwork

enum MockedResponses {
    case posts
    var response: Any {
        switch self {
        case .posts:
            let data = try? Bundle.main.readJSON(fileName: "posts")
            return data!
        }
    }
}
