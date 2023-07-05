//
//  URLSession+Extension.swift
//  ToDoList
//
//  Created by Аброрбек on 04.07.2023.
//

import Foundation

extension URLSession {
    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = dataTask(with: urlRequest) { (data, response, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    let error = NSError(domain: "URLSession", code: -1, userInfo: nil)
                    continuation.resume(throwing: error)
                }
            }
            
            let cancelationToken = CustomCancellationToken()
            
            cancelationToken.task = task
            task.resume()
        }
    }
}

class CustomCancellationToken {
    private var isCancelled = false
    private let lock = NSLock()
    var task: URLSessionDataTask? // Store the task to cancel if needed
    
    func cancel() {
        lock.lock()
        defer { lock.unlock() }
        isCancelled = true
        task?.cancel()
    }
    
    func isCancellationRequested() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return isCancelled
    }
}
