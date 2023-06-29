//
//  ToDoItemDetailsCoordinator.swift
//  ToDoList
//
//  Created by Аброрбек on 29.06.2023.
//

import UIKit

final class ToDoItemDetailsCoordinator: Coordinator {
    
    private(set) var childCoordinators: [Coordinator] = []
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
    }
    
    func start() {
//        let toDoItemListViewController = ToDoItemListViewController()
//        let toDoItemListViewModel = ToDoItemListViewModel()
//        toDoItemListViewController.viewModel = toDoItemListViewModel
//        navigationController.setViewControllers([toDoItemListViewController], animated: false)
    }
}
