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
        navigationController.navigationBar.prefersLargeTitles = true
        
        let fileCacheService = FileCacheService()
        let netwokringService = DefaultNetworkService()
        
        let toDoItemsListCoordinator = ToDoItemListCoordinator(
                                        navigationController: navigationController,
                                        fileCacheService: fileCacheService,
                                        networkingService: netwokringService)
        
        childCoordinators.append(toDoItemsListCoordinator)
        toDoItemsListCoordinator.start()
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
