//
//  ToDoItemListCoordinator.swift
//  ToDoList
//
//  Created by Аброрбек on 29.06.2023.
//

import UIKit
import SwiftUI

final class ToDoItemListCoordinator: Coordinator {
    
    private(set) var childCoordinators: [Coordinator] = []
    
    private let navigationController: UINavigationController
    private let fileCacheService: FileCacheService
    private let networkingService: NetworkingService
    let toDoItemListViewModel: ToDoItemListViewModel
    
    init(navigationController: UINavigationController, fileCacheService: FileCacheService, networkingService: NetworkingService){
        self.navigationController = navigationController
        self.fileCacheService = fileCacheService
        self.toDoItemListViewModel = ToDoItemListViewModel(fileCacheService: fileCacheService)
        self.networkingService = networkingService
    }
    
    func start() {
        toDoItemListViewModel.coordinator = self
        let toDoItemListViewController = UIHostingController(
                                            rootView: ItemsViewSwiftUI(viewModel: toDoItemListViewModel))
        navigationController.pushViewController(toDoItemListViewController, animated: false)
    }
    
    func startToDoItemDetails(with item: ToDoItem?){
        let toDoItemDetailsCoordinator = ToDoItemDetailsCoordinator(navigationController: navigationController, fileCacheService: fileCacheService, item: item, networkingService: networkingService)
        toDoItemDetailsCoordinator.parentCoordinator = self
        childCoordinators.append(toDoItemDetailsCoordinator)
        toDoItemDetailsCoordinator.start()
    }
    
    func childDidFinished(coordinator: Coordinator){
        childCoordinators.removeFirst()
    }
}
