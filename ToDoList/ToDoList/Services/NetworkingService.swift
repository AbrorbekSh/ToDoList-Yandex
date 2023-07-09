//
//  NetworkingService.swift
//  ToDoList
//
//  Created by Аброрбек on 05.07.2023.
//

import Foundation

protocol NetworkingService: AnyObject {
    func getToDoItemList() async throws -> [ToDoItem]

    func updateToDoItemList(with items: [ToDoItem]) async throws -> [ToDoItem]

    func getToDoItem(id: String) async throws -> ToDoItem
    
    func addToDoItem(item: ToDoItem) async throws -> ToDoItem
    
    func editToDoItem(item: ToDoItem) async throws -> ToDoItem

    func deleteToDoItem(id: String) async throws -> ToDoItem
}

final class DefaultNetworkService: NetworkingService {
    
    private let baseURL: String = "https://beta.mrdekk.ru/todobackend"
    private let token: String = "throatless"
    private(set) var revision: Int = 0
    
    enum NetworkingError: Error {
        case invalidURL
        case invalidServerResponse
        case failureToEncodeDTO
    }
    
    func getToDoItemList() async throws -> [ToDoItem] {
        guard let url = URL(string: "\(self.baseURL)/list") else {
            throw NetworkingError.invalidURL
        }
        let request = makeRequest(withMethod: "GET", url: url, withRevision: false)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
          throw NetworkingError.invalidServerResponse
        }
        
        let listNetworkModel = try JSONDecoder().decode(ToDoListDTO.self, from: data)
        
        if let newRevision = listNetworkModel.revision {
            self.revision = newRevision
        }

        let listTodoItems = listNetworkModel.list.map { ToDoItem.map(dto: $0) }
        
        return listTodoItems
    }
    
    func updateToDoItemList(with items: [ToDoItem]) async throws -> [ToDoItem] {
        guard let url = URL(string: "\(self.baseURL)/list") else {
            throw NetworkingError.invalidURL
        }
        var request = makeRequest(withMethod: "PATCH", url: url, withRevision: true)
        
        let listNetworkModel = ToDoListDTO(
            list: items.map {
                ToDoItemDTO(from: $0)
            }
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(listNetworkModel)
        } catch {
            throw NetworkingError.failureToEncodeDTO
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
          throw NetworkingError.invalidServerResponse
        }
        
        let listNetworkModelGet = try JSONDecoder().decode(
            ToDoListDTO.self,
            from: data
        )
        
        let listTodoItems = listNetworkModelGet.list.map { ToDoItem.map(dto: $0) }

        if let newRevision = listNetworkModel.revision {
            self.revision = newRevision
        }
        
        return listTodoItems
    }
    
    func getToDoItem(id: String) async throws -> ToDoItem {
        guard let url = URL(string: "\(self.baseURL)/list/\(id)") else {
            throw NetworkingError.invalidURL
        }
        let request = makeRequest(withMethod: "GET", url: url, withRevision: false)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
          throw NetworkingError.invalidServerResponse
        }
        
        let elementNetworkModel = try JSONDecoder().decode(
            ElementDTO.self,
            from: data
        )
        
        if let newRevision = elementNetworkModel.revision {
            self.revision = newRevision
        }

        let todoItem = ToDoItem.map(dto: elementNetworkModel.element)
        
        return todoItem
    }
    
    func addToDoItem(item: ToDoItem) async throws -> ToDoItem {
        guard let url = URL(string: "\(self.baseURL)/list") else {
            throw NetworkingError.invalidURL
        }
        var request = makeRequest(withMethod: "POST", url: url, withRevision: true)
        
        // HTTP-Body
        let networkModel = ToDoItemDTO(from: item)
        let requestNetworkModel = ElementDTO(element: networkModel)
        
        request.httpBody = try JSONEncoder().encode(requestNetworkModel)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
          throw NetworkingError.invalidServerResponse
        }
        
        let elementNetworkModel = try JSONDecoder().decode(
            ElementDTO.self,
            from: data
        )
        
        if let newRevision = elementNetworkModel.revision {
            self.revision = newRevision
        }

        let todoItem = ToDoItem.map(dto: elementNetworkModel.element)
        
        return todoItem
    }
    
    func editToDoItem(item: ToDoItem) async throws -> ToDoItem {
        guard let url = URL(string: "\(self.baseURL)/list/\(item.id)") else {
            throw NetworkingError.invalidURL
        }
        var request = makeRequest(withMethod: "PUT", url: url, withRevision: true)
        
        // HTTP-Body
        let networkModel = ToDoItemDTO(from: item)
        let requestNetworkModel = ElementDTO(element: networkModel)
        
        request.httpBody = try JSONEncoder().encode(requestNetworkModel)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
          throw NetworkingError.invalidServerResponse
        }

        let elementNetworkModel = try JSONDecoder().decode(
            ElementDTO.self,
            from: data
        )
        
        if let newRevision = elementNetworkModel.revision {
            self.revision = newRevision
        }

        let todoItem = ToDoItem.map(dto: elementNetworkModel.element)
        
        return todoItem
    }
    
    func deleteToDoItem(id: String) async throws -> ToDoItem {
        guard let url = URL(string: "\(self.baseURL)/list/\(id)") else {
            throw NetworkingError.invalidURL
        }
        let request = makeRequest(withMethod: "DELETE", url: url, withRevision: true)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
          throw NetworkingError.invalidServerResponse
        }
        
        let elementNetworkModel = try JSONDecoder().decode(
            ElementDTO.self,
            from: data
        )
        
        if let newRevision = elementNetworkModel.revision {
            self.revision = newRevision
        }

        let todoItem = ToDoItem.map(dto: elementNetworkModel.element)
        
        return todoItem
    }
    
    func makeRequest(withMethod method: String, url: URL, withRevision: Bool) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = method
        urlRequest.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        
        if withRevision {
            urlRequest.setValue("\(self.revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        }
        
        return urlRequest
    }
}
