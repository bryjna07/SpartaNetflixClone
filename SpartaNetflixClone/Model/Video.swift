//
//  Video.swift
//  SpartaNetflixClone
//
//  Created by t2023-m0033 on 12/26/24.
//

import Foundation

struct VideoResponse: Codable {
    let results: [Video]
}

struct Video: Codable {
    let key: String
    let site: String
    let type: String
}
