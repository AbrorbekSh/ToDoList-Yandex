//
//  ToDoItemIDDTO.swift
//  ToDoList
//
//  Created by Аброрбек on 06.07.2023.
//

import Foundation

struct ToDoItemIDDTO: Codable {
    let status: String
    let element: ToDoItemDTO
    let revision: Int?
    
    
    enum CodingKeys: String, CodingKey {
        case status
        case element
        case revision
    }
    
    init(status: String = "ok", element: ToDoItemDTO, revision: Int = 0) {
        self.status = status
        self.element = element
        self.revision = revision
    }
}
