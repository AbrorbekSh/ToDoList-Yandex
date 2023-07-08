//
//  ToDoListDTO.swift
//  ToDoList
//
//  Created by Аброрбек on 06.07.2023.
//

import Foundation

struct ToDoListDTO: Codable {
    let status: String?
    let list: [ToDoItemDTO]
    let revision: Int?
    
    enum CodingKeys: String, CodingKey {
        case status
        case list
        case revision
    }
    
    init(
        list: [ToDoItemDTO],
        status: String? = nil,
        revision: Int? = nil
    ) {
        self.status = status
        self.list = list
        self.revision = revision
    }
}
