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

enum NetworkServiceError: Error {
    case badFormedJson
    case revisionNotMatched
    case notFound
    case serverError
}

final class DefaultNetworkService: NetworkingService {
    
    private(set) var revision: Int = 0
    private let baseURL: String = "https://beta.mrdekk.ru/todobackend"
    
    let timeout: Double = 2.0
    
    private let urlSession: URLSession
    
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    private let token: String = "throatless"
    
    private let isolationQueue = DispatchQueue(
        label: "NetworkServiceQueue",
        attributes: .concurrent
    )
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        urlSession = URLSession(configuration: config)
    }
    
    func getToDoItemList(completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        isolationQueue.async { [weak self] in
            guard
                let self = self,
                let url = URL(string: "\(self.baseURL)/list") else {
                    return
                }
            
            // URL
            var urlRequest = URLRequest(url: url)
            
            // HTTP-Method
            urlRequest.httpMethod = "GET"
            
            // HTTP-Headers
            urlRequest.allHTTPHeaderFields = [
                "Authorization": "Bearer \(self.token)"
            ]
            
            let task = self.urlSession.dataTask(with: urlRequest) { data, response, error in
                self.isolationQueue.sync(flags: .barrier) {
                    if let error = error {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                    
                    guard
                        let data = data,
                        let httpResponse = response as? HTTPURLResponse,
                        let listNetworkModel = try? self.jsonDecoder.decode(
                            ToDoListDTO.self,
                            from: data
                        ),
                        httpResponse.statusCode == 200
                    else {
                        DispatchQueue.main.async {
                            completion(.failure(NetworkServiceError.badFormedJson))
                        }
                        return
                    }
                    
                    if let newRevision = listNetworkModel.revision {
                        self.revision = newRevision
                    }
                    
                    let listTodoItems = listNetworkModel.list.map { ToDoItem.map(dto: $0) }
                    DispatchQueue.main.async {
                        completion(.success(listTodoItems))
                    }
                }
            }
            task.resume()
        }
    }
    
    func updateToDoItemList(
        with items: [ToDoItem],
        completion: @escaping (Result<[ToDoItem], Error>) -> Void
    ) {
        isolationQueue.async { [weak self] in
            guard
                let self = self,
                let url = URL(string: "\(self.baseURL)/list") else {
                    return
                }
            
            // URL
            var urlRequest = URLRequest(url: url)
            
            // HTTP-Method
            urlRequest.httpMethod = "PATCH"
            
            // HTTP-Headers
            urlRequest.allHTTPHeaderFields = [
                "Authorization": "Bearer \(self.token)",
                "X-Last-Known-Revision": "\(self.revision)"
            ]
            
            // HTTP-Body
            let listNetworkModel = ToDoListDTO(
                list: items.map {
                    ToDoItemDTO(from: $0)
                }
            )
            
            do {
                urlRequest.httpBody = try self.jsonEncoder.encode(listNetworkModel)
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
            let task = self.urlSession.dataTask(with: urlRequest) { data, response, error in
                
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                
                guard
                    let data = data,
                    let httpResponse = response as? HTTPURLResponse,
                    let listNetworkModel = try? self.jsonDecoder.decode(
                        ToDoListDTO.self,
                        from: data
                    ),
                    httpResponse.statusCode == 200
                else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkServiceError.badFormedJson))
                    }
                    return
                }
                
                if let newRevision = listNetworkModel.revision {
                    self.revision = newRevision
                }
                
                let listTodoItems = listNetworkModel.list.map { ToDoItem.map(dto: $0) }
                DispatchQueue.main.async {
                    completion(.success(listTodoItems))
                }
            }
            task.resume()
        }
    }
    
    func getToDoItem(
        id: String,
        completion: @escaping (Result<ToDoItem, Error>
        ) -> Void) {
        isolationQueue.async { [weak self] in
            guard
                let self = self,
                let url = URL(string: "\(self.baseURL)/list/\(id)") else {
                    return
                }
            
            // URL
            var urlRequest = URLRequest(url: url)
            
            // HTTP-Method
            urlRequest.httpMethod = "GET"
            
            // HTTP-Headers
            urlRequest.allHTTPHeaderFields = [
                "Authorization": "Bearer \(self.token)"
            ]
            
            let task = self.urlSession.dataTask(with: urlRequest) { data, response, error in
                
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                
                guard
                    let data = data,
                    let httpResponse = response as? HTTPURLResponse,
                    let elementNetworkModel = try? self.jsonDecoder.decode(
                        ElementDTO.self,
                        from: data
                    ),
                    httpResponse.statusCode == 200
                else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkServiceError.badFormedJson))
                    }
                    return
                }
                
                if let newRevision = elementNetworkModel.revision {
                    self.revision = newRevision
                }
                
                let todoItem = ToDoItem.map(dto: elementNetworkModel.element)
                DispatchQueue.main.async {
                    completion(.success(todoItem))
                }
            }
            task.resume()
        }
    }
    
    func addToDoItem(
        item: ToDoItem,
        completion: @escaping (Result<ToDoItem, Error>
        ) -> Void) {
        isolationQueue.async { [weak self] in
            guard
                let self = self,
                let url = URL(string: "\(self.baseURL)/list") else {
                    return
                }
            
            // URL
            var urlRequest = URLRequest(url: url)
            
            // HTTP-Method
            urlRequest.httpMethod = "POST"
            
            // HTTP-Headers
            urlRequest.allHTTPHeaderFields = [
                "Authorization": "Bearer \(self.token)",
                "X-Last-Known-Revision": "\(self.revision)"
            ]
            
            // HTTP-Body
            let networkModel = ToDoItemDTO(from: item)
            let requestNetworkModel = ElementDTO(element: networkModel)
            
            do {
                urlRequest.httpBody = try self.jsonEncoder.encode(requestNetworkModel)
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
            let task = self.urlSession.dataTask(with: urlRequest) { data, response, error in
                
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                
                guard
                    let data = data,
                    let httpResponse = response as? HTTPURLResponse,
                    let elementNetworkModel = try? self.jsonDecoder.decode(
                        ElementDTO.self,
                        from: data
                    ),
                    httpResponse.statusCode == 200
                else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkServiceError.badFormedJson))
                    }
                    return
                }
                
                if let newRevision = elementNetworkModel.revision {
                    self.revision = newRevision
                }
                
                let todoItem = ToDoItem.map(dto: elementNetworkModel.element)
                DispatchQueue.main.async {
                    completion(.success(todoItem))
                }
                
            }
            task.resume()
        }
    }
    
    func editToDoItem(
        item: ToDoItem,
        completion: @escaping (Result<ToDoItem, Error>
        ) -> Void) {
        isolationQueue.async { [weak self] in
            guard
                let self = self,
                let url = URL(string: "\(self.baseURL)/list/\(item.id)") else {
                    return
                }
            
            // URL
            var urlRequest = URLRequest(url: url)
            
            // HTTP-Method
            urlRequest.httpMethod = "PUT"
            
            // HTTP-Headers
            urlRequest.allHTTPHeaderFields = [
                "Authorization": "Bearer \(self.token)",
                "X-Last-Known-Revision": "\(self.revision)"
            ]
            
            // HTTP-Body
            let networkModel = ToDoItemDTO(from: item)
            let requestNetworkModel = ElementDTO(element: networkModel)
            
            do {
                urlRequest.httpBody = try self.jsonEncoder.encode(requestNetworkModel)
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
            let task = self.urlSession.dataTask(with: urlRequest) { data, response, error in
                
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                
                guard
                    let data = data,
                    let httpResponse = response as? HTTPURLResponse,
                    let elementNetworkModel = try? self.jsonDecoder.decode(
                        ElementDTO.self,
                        from: data
                    ),
                    httpResponse.statusCode == 200
                else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkServiceError.badFormedJson))
                    }
                    return
                }
                
                if let newRevision = elementNetworkModel.revision {
                    self.revision = newRevision
                }
                
                let todoItem = ToDoItem.map(dto: elementNetworkModel.element)
                DispatchQueue.main.async {
                    completion(.success(todoItem))
                }
            }
            task.resume()
        }
    }
    
    func deleteToDoItem(
        id: String,
        completion: @escaping (Result<ToDoItem, Error>
        ) -> Void) {
        isolationQueue.async { [weak self] in
            guard
                let self = self,
                let url = URL(string: "\(self.baseURL)/list/\(id)") else {
                    return
                }
            
            // URL
            var urlRequest = URLRequest(url: url)
            
            // HTTP-Method
            urlRequest.httpMethod = "DELETE"
            
            // HTTP-Headers
            urlRequest.allHTTPHeaderFields = [
                "Authorization": "Bearer \(self.token)",
                "X-Last-Known-Revision": "\(self.revision)"
            ]
            
            let task = self.urlSession.dataTask(with: urlRequest) { data, response, error in
                
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                
                guard
                    let data = data,
                    let httpResponse = response as? HTTPURLResponse,
                    let elementNetworkModel = try? self.jsonDecoder.decode(
                        ElementDTO.self,
                        from: data
                    ),
                    httpResponse.statusCode == 200
                else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkServiceError.badFormedJson))
                    }
                    return
                }
                
                if let newRevision = elementNetworkModel.revision {
                    self.revision = newRevision
                }
                
                let todoItem = ToDoItem.map(dto: elementNetworkModel.element)
                DispatchQueue.main.async {
                    completion(.success(todoItem))
                }
            }
            task.resume()
        }
    }
}

//protocol NetworkingService: AnyObject {
//    func getToDoItemList(
//        completion: @escaping (Result<[ToDoItem], Error>) -> Void
//    )
//
//    func updateToDoItemList(
//        with items: [ToDoItem],
//        completion: @escaping (Result<[ToDoItem], Error>) -> Void
//    )
//
//    func getToDoItem(
//        id: String,
//        completion: @escaping (Result<ToDoItem, Error>) -> Void
//    )
//
//    func addToDoItem(
//        item: ToDoItem,
//        completion: @escaping (Result<ToDoItem, Error>) -> Void
//    )
//
//    func editToDoItem(
//        item: ToDoItem,
//        completion: @escaping (Result<ToDoItem, Error>) -> Void
//    )
//
//    func deleteToDoItem(
//        id: String,
//        completion: @escaping (Result<ToDoItem, Error>) -> Void
//    )
//}
//
//enum NetworkingServiceErrors: Error {
//    case failureGettingData
//}
//
//final class DefaultNetworkingService: NetworkingService {
//
//    private let baseURL: String = "https://beta.mrdekk.ru/todobackend"
////    private let token: String = "Shanazarov_A"
//    private var revision: Int = 0
//    private let urlSession: URLSession
//    private let networkingQueue = DispatchQueue(label: "networkingQueue", attributes: .concurrent)
//
//    private let token: String = "throatless"
//
//    private let isolationQueue = DispatchQueue(
//        label: "NetworkServiceQueue",
//        attributes: .concurrent
//    )
//
//    init(){
//        let defaultConfiguration = URLSessionConfiguration.default
//        urlSession = URLSession(configuration: defaultConfiguration)
//    }
//
//    func getToDoItemList(completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
//        networkingQueue.async { [weak self] in
//            guard
//                let strongSelf = self,
//                let url = URL(string: "\(strongSelf.baseURL)/list")
//            else {
//                return
//            }
//
//            var request = URLRequest(url: url)
//            request.httpMethod = "GET"
//            request.allHTTPHeaderFields = [
//                "Authorization": "Bearer \(strongSelf.token)"
//            ]
//
//            let task = strongSelf.urlSession.dataTask(with: request) { data, response, error in
//                guard
//                    let data = data,
//                    let response = response as? HTTPURLResponse,
//                    let list = try? JSONDecoder().decode(ToDoListDTO.self, from: data),
//                    error == nil,
//                    response.statusCode == 200
//                else {
//                    DispatchQueue.main.async {
//                        completion(.failure(NetworkingServiceErrors.failureGettingData))
//                    }
//                    return
//                }
//
//                let formedList = list.list.map { itemDTO in
//                    ToDoItem.convertFromDTO(dto: itemDTO)
//                }
//                DispatchQueue.main.async {
//                    completion(.success(formedList))
//                }
//
//                if let revision = list.revision {
//                    strongSelf.revision = revision
//                }
//            }
//
//            task.resume()
//        }
//    }
//
//    func updateToDoItemList(with items: [ToDoItem], completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
//        networkingQueue.async { [weak self] in
//            guard
//                let strongSelf = self,
//                let url = URL(string: "\(strongSelf.baseURL)/list")
//            else {
//                return
//            }
//
//            var request = URLRequest(url: url)
//            request.httpMethod = "PATCH"
//            request.allHTTPHeaderFields = [
//                "Authorization": "Bearer \(strongSelf.token)",
//                "X-Last-Known-Revision": "\(strongSelf.revision)"
//            ]
//
//            let list = items.map { item in
//                ToDoItemDTO(from: item)
//            }
//
//            let toDoListDTO = ToDoListDTO(list: list, revision: strongSelf.revision)
//
//            do {
//                request.httpBody = try JSONEncoder().encode(toDoListDTO)
//            } catch {
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//            }
//
//            let task = strongSelf.urlSession.dataTask(with: request) { data, response, error in
//                guard
//                    let data = data,
//                    let response = response as? HTTPURLResponse,
//                    let list = try? JSONDecoder().decode(ToDoListDTO.self, from: data),
//                    error == nil,
//                    response.statusCode == 200
//                else {
//                    DispatchQueue.main.async {
//                        completion(.failure(NetworkingServiceErrors.failureGettingData))
//                    }
//                    return
//                }
//
//                let formedList = list.list.map { itemDTO in
//                    ToDoItem.convertFromDTO(dto: itemDTO)
//                }
//                DispatchQueue.main.async {
//                    completion(.success(formedList))
//                }
//
//                if let revision = list.revision {
//                    strongSelf.revision = revision
//                }
//            }
//
//            task.resume()
//        }
//    }
//
//
//    func getToDoItem(id: String, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
//        networkingQueue.async { [weak self] in
//            guard
//                let strongSelf = self,
//                let url = URL(string: "\(strongSelf.baseURL)/list/\(id)")
//            else {
//                return
//            }
//
//            var request = URLRequest(url: url)
//            request.httpMethod = "GET"
//            request.allHTTPHeaderFields = [
//                "Authorization": "Bearer \(strongSelf.token)",
//            ]
//
//            let task = strongSelf.urlSession.dataTask(with: request) { data, response, error in
//                guard
//                    let data = data,
//                    let response = response as? HTTPURLResponse,
//                    let item = try? JSONDecoder().decode(ToDoItemIDDTO.self, from: data),
//                    error == nil,
//                    response.statusCode == 200
//                else {
//                    DispatchQueue.main.async {
//                        completion(.failure(NetworkingServiceErrors.failureGettingData))
//                    }
//                    return
//                }
//
//                let newItem = ToDoItem.convertFromDTO(dto: item.element)
//                DispatchQueue.main.async {
//                    completion(.success(newItem))
//                }
//
//                if let revision = item.revision {
//                    strongSelf.revision = revision
//                }
//            }
//
//            task.resume()
//        }
//    }
//
//    func addToDoItem(item: ToDoItem, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
//        networkingQueue.async { [weak self] in
//            guard
//                let strongSelf = self,
//                let url = URL(string: "\(strongSelf.baseURL)/list")
//            else {
//                return
//            }
//
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            print("\(strongSelf.revision)")
//            request.allHTTPHeaderFields = [
//                "Authorization": "Bearer \(strongSelf.token)",
//                "X-Last-Known-Revision": "\(strongSelf.revision)"
//            ]
//
//            let itemDTO = ToDoItemDTO(from: item)
//
//            do {
//                request.httpBody = try JSONEncoder().encode(itemDTO)
//            } catch {
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//            }
//
//            let task = strongSelf.urlSession.dataTask(with: request) { data, response, error in
//
//                strongSelf.networkingQueue.sync (flags: .barrier) {
//                    print(data)
//                    print(response)
//                    print(error)
//                    guard
//                        let data = data,
//                        let response = response as? HTTPURLResponse,
//                        let item = try? JSONDecoder().decode(ToDoItemIDDTO.self, from: data),
//                        error == nil,
//                        response.statusCode == 200
//                    else {
//                        DispatchQueue.main.async {
//                            completion(.failure(NetworkingServiceErrors.failureGettingData))
//                        }
//                        return
//                    }
//
//                    let newItem = ToDoItem.convertFromDTO(dto: item.element)
//                    DispatchQueue.main.async {
//                        completion(.success(newItem))
//                    }
//
//                    if let revision = item.revision {
//                        strongSelf.revision = revision
//                    }
//                }
//            }
//                task.resume()
//        }
//    }
//
//    func deleteToDoItem(id: String, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
//        networkingQueue.async { [weak self] in
//            guard
//                let strongSelf = self,
//                let url = URL(string: "\(strongSelf.baseURL)/list/\(id)")
//            else {
//                return
//            }
//
//            var request = URLRequest(url: url)
//            request.httpMethod = "DELETE"
//            request.allHTTPHeaderFields = [
//                "Authorization": "Bearer \(strongSelf.token)",
//                "X-Last-Known-Revision": "\(strongSelf.revision)"
//            ]
//
//            let task = strongSelf.urlSession.dataTask(with: request) { data, response, error in
//                guard
//                    let data = data,
//                    let response = response as? HTTPURLResponse,
//                    let item = try? JSONDecoder().decode(ToDoItemIDDTO.self, from: data),
//                    error == nil,
//                    response.statusCode == 200
//                else {
//                    DispatchQueue.main.async {
//                        completion(.failure(NetworkingServiceErrors.failureGettingData))
//                    }
//                    return
//                }
//
//                let newItem = ToDoItem.convertFromDTO(dto: item.element)
//                DispatchQueue.main.async {
//                    completion(.success(newItem))
//                }
//
//                if let revision = item.revision {
//                    strongSelf.revision = revision
//                }
//            }
//
//            task.resume()
//        }
//    }
//
//    func editToDoItem(item: ToDoItem, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
//        networkingQueue.async { [weak self] in
//            guard
//                let strongSelf = self,
//                let url = URL(string: "\(strongSelf.baseURL)/list/\(item.id)")
//            else {
//                return
//            }
//
//            var request = URLRequest(url: url)
//            request.httpMethod = "PUT"
//            request.allHTTPHeaderFields = [
//                "Authorization": "Bearer \(strongSelf.token)",
//                "X-Last-Known-Revision": "\(strongSelf.revision)"
//            ]
//
//            let itemDTO = ToDoItemDTO(from: item)
//
//            do {
//                request.httpBody = try JSONEncoder().encode(itemDTO)
//            } catch {
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//            }
//
//            let task = strongSelf.urlSession.dataTask(with: request) { data, response, error in
//                guard
//                    let data = data,
//                    let response = response as? HTTPURLResponse,
//                    let item = try? JSONDecoder().decode(ToDoItemIDDTO.self, from: data),
//                    error == nil,
//                    response.statusCode == 200
//                else {
//                    DispatchQueue.main.async {
//                        completion(.failure(NetworkingServiceErrors.failureGettingData))
//                    }
//                    return
//                }
//
//                let newItem = ToDoItem.convertFromDTO(dto: item.element)
//                DispatchQueue.main.async {
//                    completion(.success(newItem))
//                }
//
//                if let revision = item.revision {
//                    strongSelf.revision = revision
//                }
//            }
//
//            task.resume()
//        }
//    }
//}
