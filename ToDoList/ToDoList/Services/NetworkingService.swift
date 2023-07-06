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
    
    
}

enum NetworkingServiceErrors: Error {
    case failureGettingData
}

final class DefaultNetworkingService: NetworkingService {
    
    private let baseURL: String = "https://beta.mrdekk.ru/todobackend"
    private let token: String = "Shanazarov_A"
    private var revision: Int = 0
    private let urlSession: URLSession
    private let networkingQueue = DispatchQueue(label: "networkingQueue", attributes: .concurrent)
    
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
                "Authorization": "Bearer <\(strongSelf.token)>"
            ]
            
            let task = strongSelf.urlSession.dataTask(with: request) { data, response, error in
                guard
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    let list = try? JSONDecoder().decode(ToDoList.self, from: data),
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
                
                strongSelf.revision = list.revision
            }
            
            task.resume()
        }
    }
}
