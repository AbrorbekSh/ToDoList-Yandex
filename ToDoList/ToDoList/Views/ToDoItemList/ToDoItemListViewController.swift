//
//  ToDoItemList.swift
//  ToDoList
//
//  Created by Аброрбек on 26.06.2023.
//

import UIKit

final class ToDoItemListViewController: UIViewController {
    
    private let viewModel: ToDoItemListViewModel
    
    init(viewModel: ToDoItemListViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Elements
    
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
            action: #selector(addNewItemPressed),
            for: .touchUpInside
        )
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        
        return button
    }()
    
    //MARK: - LifeCycle
    
    override func loadView() {
        super.loadView()
        
        viewModel.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewModel()
        viewModel.viewDidLoad()
        setupView()
        setupLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.viewWillDisappear()
    }
    
    
    //MARK: - Setup
    
    private func setupView(){
        title = viewModel.title
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = UIColor.backgroundColor
        
        view.addSubview(tableView)
        view.addSubview(addTodoItemButton)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupViewModel(){
        viewModel.reloadTableView = {
            self.tableView.reloadData()
        }
    }
    
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
            )
        ])
    }
    
    //MARK: - Methods
    
    @objc
    private func addNewItemPressed(_: UIButton) {
        viewModel.addNewItemPressed()
    }
}

//MARK: - UITableViewDataSource

extension ToDoItemListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getNumberofItems() + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == viewModel.getNumberofItems() {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NewToDoItemCell.identifier, for: indexPath) as? NewToDoItemCell else {
                    return UITableViewCell()
                }
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoItemListCell.identifier, for: indexPath) as? ToDoItemListCell else {
                return UITableViewCell()
            }
        
        viewModel.updateCell(at: indexPath) { item in
            cell.update(toDoItem: item)
        }

        return cell
    }
    
    
}

//MARK: - UITableViewDelegate

extension ToDoItemListViewController:  UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        if indexPath.row == viewModel.getNumberofItems() {
            return nil
        }
        
        let markAsDoneButton = UIContextualAction(style: .normal, title: "") { [weak self] (_, _, completion) in
            completion(true)
            guard let strongSelf = self else {
                return
            }
            strongSelf.viewModel.markAsDone(at: indexPath)
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
        
        if indexPath.row == viewModel.getNumberofItems() {
            return nil
        }
        
        let deleteButton = UIContextualAction(style: .destructive, title: "") { [weak self] (_, _, completion) in
            completion(true)
            guard let strongSelf = self else {
                return
            }
            strongSelf.viewModel.deleteItem(at: indexPath)
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
            guard let strongSelf = self else {
                return
            }
            strongSelf.viewModel.openDetailsView(at: indexPath)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.getNumberofItems() {
            viewModel.addNewItemPressed()
        } else {
            viewModel.openDetailsView(at: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                        byRoundingCorners: [.topLeft, .topRight],
                                        cornerRadii: CGSize (width: 16, height: 16))
            let shape = CAShapeLayer()
            shape.path = maskPath.cgPath
            cell.layer.mask = shape
        } else if indexPath.row == viewModel.getNumberofItems() {
            let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                        byRoundingCorners: [.bottomLeft, .bottomRight],
                                        cornerRadii: CGSize (width: 16, height: 16))
            let shape = CAShapeLayer()
            shape.path = maskPath.cgPath
            cell.layer.mask = shape
        } else {
            let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                        byRoundingCorners: [.bottomLeft, .bottomRight, .topLeft, .topRight],
                                        cornerRadii: CGSize (width: 0, height: 0))
            let shape = CAShapeLayer()
            shape.path = maskPath.cgPath
            cell.layer.mask = shape
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableViewHeader.identifier) as? TableViewHeader
        header?.delegate = viewModel
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        32
    }
}

