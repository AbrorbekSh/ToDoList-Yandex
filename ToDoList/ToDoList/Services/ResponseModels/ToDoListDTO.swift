//
//  ToDoListDTO.swift
//  ToDoList
//
//  Created by Аброрбек on 06.07.2023.
//

import Foundation

struct ToDoList: Codable {
    let status: String
    let list: [ToDoItemDTO]
    let revision: Int
    
    init(status: String = "OK", list: [ToDoItemDTO], revision: Int) {
        self.status = status
        self.list = list
        self.revision = revision
    }
    
    enum CodingKeys: String, CodingKey {
        case status
        case list
        case revision
    }
}
