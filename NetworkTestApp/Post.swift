//
//  Post.swift
//  NetworkTestApp
//
//  Created by Lito Arias on 19/05/2019.
//  Copyright © 2019 MonnoApps. All rights reserved.
//

import Foundation

struct Post: Decodable {
    var userId: Int
    var id: Int
    var title: String
    var body: String
}

struct Tag: Codable {
    
    var id: String?
    var titulo: String?
    var selected: Bool = false
    
    private enum CodingKeys: String, CodingKey { case id, titulo }
    
    static func save(tag: [Tag]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(tag) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "savedTags")
        }
    }
}
