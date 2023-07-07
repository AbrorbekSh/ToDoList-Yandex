//
//  URLSession+Extension.swift
//  ToDoList
//
//  Created by Аброрбек on 04.07.2023.
//

import Foundation

extension URLSession {
    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        var task: URLSessionDataTask?
         return try await withTaskCancellationHandler {
             try await withCheckedThrowingContinuation { continuation in
                 task = dataTask(with: urlRequest) { data, response, error in
                     guard
                         let data = data,
                         let response = response,
                         error == nil
                     else {
                         if let error = error {
                             continuation.resume(throwing: error )
                         }
                         return
                     }
                     continuation.resume(returning: (data, response))
                     }
                 task?.resume()
             }
         } onCancel: { [weak task] in
             task?.cancel()
         }
     }
}

