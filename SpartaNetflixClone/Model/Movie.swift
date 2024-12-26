//
//  Movie.swift
//  SpartaNetflixClone
//
//  Created by t2023-m0033 on 12/26/24.
//

import Foundation

struct MovieResponse: Codable {
    let results: [Movie]
}

struct Movie: Codable {
    let id: Int?
    let title: String?
    let posterPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case posterPath = "poster_path"
    }
}
