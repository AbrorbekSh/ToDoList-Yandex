//
//  ToDoItemIDDTO.swift
//  ToDoList
//
//  Created by Аброрбек on 06.07.2023.
//

import Foundation

struct ToDoItemIDDTO: Codable {
    let status: String?
    let element: ToDoItemDTO
    let revision: Int?
    
    init(status: String, element: ToDoItemDTO, revision: Int) {
        self.status = status
        self.element = element
        self.revision = revision
    }
    
    enum CodingKeys: String, CodingKey {
        case status
        case element
        case revision
    }
}
