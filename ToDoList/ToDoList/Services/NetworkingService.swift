//
//  NetworkingService.swift
//  ToDoList
//
//  Created by Аброрбек on 05.07.2023.
//

import Foundation

protocol NetworkingService: AnyObject {
    func getToDoItemList(
        completion: @escaping (Result<[ToDoItem], Error>) -> Void
    )
    
    func updateToDoItemList(
        with items: [ToDoItem],
        completion: @escaping (Result<[ToDoItem], Error>) -> Void
    )
    
    func getToDoItem(
        id: String,
        completion: @escaping (Result<ToDoItem, Error>) -> Void
    )
    
    func addToDoItem(
        item: ToDoItem,
        completion: @escaping (Result<ToDoItem, Error>) -> Void
    )
    
    func editToDoItem(
        item: ToDoItem,
        completion: @escaping (Result<ToDoItem, Error>) -> Void
    )
    
    func deleteToDoItem(
        id: String,
        completion: @escaping (Result<ToDoItem, Error>) -> Void
    )
}

enum NetworkingServiceErrors: Error {
    case failureGettingData
}

final class DefaultNetworkingService: NetworkingService {
    
    private let baseURL: String = "https://beta.mrdekk.ru/todobackend"
//    private let token: String = "Shanazarov_A"
    private var revision: Int = 0
    private let urlSession: URLSession
    private let networkingQueue = DispatchQueue(label: "networkingQueue", attributes: .concurrent)
    
    private let token: String = "throatless"
    
    private let isolationQueue = DispatchQueue(
        label: "NetworkServiceQueue",
        attributes: .concurrent
    )
    
    init(){
        let defaultConfiguration = URLSessionConfiguration.default
        urlSession = URLSession(configuration: defaultConfiguration)
    }
    
    func getToDoItemList(completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        networkingQueue.async { [weak self] in
            guard
                let strongSelf = self,
                let url = URL(string: "\(strongSelf.baseURL)/list")
            else {
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = [
                "Authorization": "Bearer \(strongSelf.token)"
            ]

            let task = strongSelf.urlSession.dataTask(with: request) { data, response, error in
                guard
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    let list = try? JSONDecoder().decode(ToDoListDTO.self, from: data),
                    error == nil,
                    response.statusCode == 200
                else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkingServiceErrors.failureGettingData))
                    }
                    return
                }

                let formedList = list.list.map { itemDTO in
                    ToDoItem.convertFromDTO(dto: itemDTO)
                }
                DispatchQueue.main.async {
                    completion(.success(formedList))
                }

//                strongSelf.revision = list.revision
            }

            task.resume()
        }
    }
    
    func updateToDoItemList(with items: [ToDoItem], completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        networkingQueue.async { [weak self] in
            guard
                let strongSelf = self,
                let url = URL(string: "\(strongSelf.baseURL)/list")
            else {
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.allHTTPHeaderFields = [
                "Authorization": "Bearer \(strongSelf.token)",
                "X-Last-Known-Revision": "\(strongSelf.revision)"
            ]
            
            let list = items.map { item in
                ToDoItemDTO(from: item)
            }
            
            let toDoListDTO = ToDoListDTO(list: list, revision: strongSelf.revision)
            
            do {
                request.httpBody = try JSONEncoder().encode(toDoListDTO)
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
            let task = strongSelf.urlSession.dataTask(with: request) { data, response, error in
                guard
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    let list = try? JSONDecoder().decode(ToDoListDTO.self, from: data),
                    error == nil,
                    response.statusCode == 200
                else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkingServiceErrors.failureGettingData))
                    }
                    return
                }
                
                let formedList = list.list.map { itemDTO in
                    ToDoItem.convertFromDTO(dto: itemDTO)
                }
                DispatchQueue.main.async {
                    completion(.success(formedList))
                }
                
//                strongSelf.revision = list.revision
            }
            
            task.resume()
        }
    }
    
    
    func getToDoItem(id: String, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        networkingQueue.async { [weak self] in
            guard
                let strongSelf = self,
                let url = URL(string: "\(strongSelf.baseURL)/list/\(id)")
            else {
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = [
                "Authorization": "Bearer \(strongSelf.token)",
            ]
            
            let task = strongSelf.urlSession.dataTask(with: request) { data, response, error in
                guard
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    let item = try? JSONDecoder().decode(ToDoItemIDDTO.self, from: data),
                    error == nil,
                    response.statusCode == 200
                else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkingServiceErrors.failureGettingData))
                    }
                    return
                }
                
                let newItem = ToDoItem.convertFromDTO(dto: item.element)
                DispatchQueue.main.async {
                    completion(.success(newItem))
                }
                
//                strongSelf.revision = item.revision
            }
            
            task.resume()
        }
    }
    
    func addToDoItem(item: ToDoItem, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        networkingQueue.async { [weak self] in
            guard
                let strongSelf = self,
                let url = URL(string: "\(strongSelf.baseURL)/list")
            else {
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = [
                "Authorization": "Bearer \(strongSelf.token)",
                "X-Last-Known-Revision": "\(strongSelf.revision)"
            ]
            
            let itemDTO = ToDoItemDTO(from: item)
            
            do {
                request.httpBody = try JSONEncoder().encode(itemDTO)
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
            let task = strongSelf.urlSession.dataTask(with: request) { data, response, error in
                guard
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    let item = try? JSONDecoder().decode(ToDoItemIDDTO.self, from: data),
                    error == nil,
                    response.statusCode == 200
                else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkingServiceErrors.failureGettingData))
                    }
                    return
                }

                let newItem = ToDoItem.convertFromDTO(dto: item.element)
                DispatchQueue.main.async {
                    completion(.success(newItem))
                }

//                strongSelf.revision = item.revision
            }

            task.resume()
        }
    }
    
    func deleteToDoItem(id: String, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        networkingQueue.async { [weak self] in
            guard
                let strongSelf = self,
                let url = URL(string: "\(strongSelf.baseURL)/list/\(id)")
            else {
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.allHTTPHeaderFields = [
                "Authorization": "Bearer \(strongSelf.token)",
                "X-Last-Known-Revision": "\(strongSelf.revision)"
            ]
            
            let task = strongSelf.urlSession.dataTask(with: request) { data, response, error in
                guard
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    let item = try? JSONDecoder().decode(ToDoItemIDDTO.self, from: data),
                    error == nil,
                    response.statusCode == 200
                else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkingServiceErrors.failureGettingData))
                    }
                    return
                }
                
                let newItem = ToDoItem.convertFromDTO(dto: item.element)
                DispatchQueue.main.async {
                    completion(.success(newItem))
                }
                
//                strongSelf.revision = item.revision
            }
            
            task.resume()
        }
    }
    
    func editToDoItem(item: ToDoItem, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        networkingQueue.async { [weak self] in
            guard
                let strongSelf = self,
                let url = URL(string: "\(strongSelf.baseURL)/list/\(item.id)")
            else {
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.allHTTPHeaderFields = [
                "Authorization": "Bearer \(strongSelf.token)",
                "X-Last-Known-Revision": "\(strongSelf.revision)"
            ]
            
            let itemDTO = ToDoItemDTO(from: item)
            
            do {
                request.httpBody = try JSONEncoder().encode(itemDTO)
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
            let task = strongSelf.urlSession.dataTask(with: request) { data, response, error in
                guard
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    let item = try? JSONDecoder().decode(ToDoItemIDDTO.self, from: data),
                    error == nil,
                    response.statusCode == 200
                else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkingServiceErrors.failureGettingData))
                    }
                    return
                }
                
                let newItem = ToDoItem.convertFromDTO(dto: item.element)
                DispatchQueue.main.async {
                    completion(.success(newItem))
                }
                
//                strongSelf.revision = item.revision
            }
            
            task.resume()
        }
    }
}
