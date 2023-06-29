//
//  ToDoItemList.swift
//  ToDoList
//
//  Created by Аброрбек on 26.06.2023.
//

import UIKit

final class ToDoItemListViewController: UIViewController {
    
    var viewModel: ToDoItemListViewModel?
    var list: [ToDoItem] = []
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
        table.backgroundColor = UIColor.backgroundColor
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 56
        
        table.register(ToDoItemListCell.self, forCellReuseIdentifier: ToDoItemListCell.identifier)
        table.register(NewToDoItemCell.self, forCellReuseIdentifier: NewToDoItemCell.identifier)
        table.register(TableViewHeader.self, forHeaderFooterViewReuseIdentifier: TableViewHeader.identifier)
        
        return table
    }()
    
    private lazy var addTodoItemButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "plus",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold))
        config.cornerStyle = .capsule
        button.configuration = config
        button.tintColor = .systemBlue
        
        button.addTarget(
            self,
            action: #selector(didTapAddTodoItemButton),
            for: .touchUpInside
        )
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel?.title
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = UIColor.backgroundColor
        
        view.addSubview(tableView)
        view.addSubview(addTodoItemButton)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        setupLayout()
    }
    
    
    //MARK: - Setup
    
    private func setupLayout(){
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            )
        ])
        
        NSLayoutConstraint.activate([
            addTodoItemButton.widthAnchor.constraint(
                equalToConstant: 50
            ),
            addTodoItemButton.heightAnchor.constraint(
                equalToConstant: 50
            ),
            addTodoItemButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            addTodoItemButton.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -54
            )])
    }
            
    @objc
    private func didTapAddTodoItemButton(_: UIButton) {
        viewModel?.didTapAddTodoItemButton()
    }
}

extension ToDoItemListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 4 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NewToDoItemCell.identifier, for: indexPath) as? NewToDoItemCell else {
                    return UITableViewCell()
                }
            cell.selectionStyle = .none
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoItemListCell.identifier, for: indexPath) as? ToDoItemListCell else {
                return UITableViewCell()
            }
        cell.selectionStyle = .none
        
        let item = ToDoItem(
                            id: "123456789",
                            text: "Купить что-то, где-то, зачем-то, но зачем не очень понятно, но точно чтобы поJIOJOIJOIJOIJOIJOIJOIJIOJJOIJOIJIOJIOJIIIPBU[OBO[B[OBO[BONPN ONPUN",
                            priority: .low,
                            deadline: Date.now,
                            isCompleted: false,
                            createdAt: Date.now,
                            editedAt: Date.now,
                            color: "#FF453A"
        )
        
        let item2 = ToDoItem(
                            id: "123456789",
                            text: "Купить что-то, где-то, зачем-то",
                            priority: .high,
                            deadline: Date.now,
                            isCompleted: false,
                            createdAt: Date.now,
                            editedAt: Date.now,
                            color: "#FF453A"
        )
        if indexPath.row % 2 == 0 {
            cell.configure(toDoItem: item)
            return cell
        }
        cell.configure(toDoItem: item2)

        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        //if last dont perform anything
        
        let markAsDoneButton = UIContextualAction(style: .normal, title: "") { [weak self] (_, _, completion) in
            completion(true)
        }
        let configMarkAsDone = UIImage.SymbolConfiguration(
            font: .boldSystemFont(ofSize: 20),
            scale: .large
        )
        markAsDoneButton.image = UIImage(
            systemName: "checkmark.circle.fill",
            withConfiguration: configMarkAsDone
        )
        markAsDoneButton.backgroundColor = .green
        
        let config = UISwipeActionsConfiguration(actions: [markAsDoneButton])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        //if last dont perform anything
        
        let deleteButton = UIContextualAction(style: .destructive, title: "") { [weak self] (_, _, completion) in
            completion(true)
        }
        let configDelete = UIImage.SymbolConfiguration(
            font: .boldSystemFont(ofSize: 20),
            scale: .large
        )
        deleteButton.image = UIImage(
            systemName: "trash.fill",
            withConfiguration: configDelete
        )
        deleteButton.backgroundColor = .red
        
        let infoButton = UIContextualAction(style: .destructive, title: "") { [weak self] (_, _, completion) in
            completion(true)
        }
        let configInfo = UIImage.SymbolConfiguration(
            font: .boldSystemFont(ofSize: 20),
            scale: .large
        )
        infoButton.image = UIImage(
            systemName: "info.circle.fill",
            withConfiguration: configInfo
        )
        infoButton.backgroundColor = .lightGray
        
        let config = UISwipeActionsConfiguration(actions: [deleteButton, infoButton])
        config.performsFirstActionWithFullSwipe = true
        return config
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableViewHeader.identifier) as? TableViewHeader
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        32
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                        byRoundingCorners: [.topLeft, .topRight],
                                        cornerRadii: CGSize (width: 16, height: 16))
            let shape = CAShapeLayer()
            shape.path = maskPath.cgPath
            cell.layer.mask = shape
        } else if indexPath.row == 4 {
            let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                        byRoundingCorners: [.bottomLeft, .bottomRight],
                                        cornerRadii: CGSize (width: 16, height: 16))
            let shape = CAShapeLayer()
            shape.path = maskPath.cgPath
            cell.layer.mask = shape
        }
    }
}

