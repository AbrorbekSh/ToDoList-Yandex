//
//  AppCoordinator.swift
//  ToDoList
//
//  Created by Аброрбек on 29.06.2023.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get }
    func start()
}

final class AppCoordinator: Coordinator {
    
    private(set) var childCoordinators: [Coordinator] = []
    
    private let window: UIWindow
    
    init(window: UIWindow){
        self.window = window
    }
    
    func start() {
        let navigationController = UINavigationController()
        let fileCache = FileCache()
        let netwokringService = DefaultNetworkService()
        
        let toDoItemsListCoordinator = ToDoItemListCoordinator(navigationController: navigationController, fileCache: fileCache, networkingService: netwokringService)
        childCoordinators.append(toDoItemsListCoordinator)
        toDoItemsListCoordinator.start()
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
