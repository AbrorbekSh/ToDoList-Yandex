//
//  ElementDTO.swift
//  ToDoList
//
//  Created by Аброрбек on 08.07.2023.
//

import Foundation

struct ElementDTO: Codable {
    let status: String?
    let element: ToDoItemDTO
    let revision: Int?
    
    enum CodingKeys: String, CodingKey {
        case status
        case element
        case revision
    }
    
    init(
        element: ToDoItemDTO,
        status: String? = nil,
        revision: Int? = nil
    ) {
        self.status = status
        self.element = element
        self.revision = revision
    }
}
