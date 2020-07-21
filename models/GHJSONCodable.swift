//
//  GHJSONCodable.swift
//  gitfrenz
//
//  Created by m interrupt on 7/17/20.
//  Copyright © 2020 m interrupt. All rights reserved.
//

import Foundation

enum GHJSONCodable {
    
    struct User: Codable { }
    struct Repository: Codable {
        let name: String
        let url: String
        let api_url: String
        
        private enum CodingKeys: String, CodingKey {
            case name = "name"
            case url = "html_url"
            case api_url = "url"
        }
    }
}

