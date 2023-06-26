//
//  ToDoItemList.swift
//  ToDoList
//
//  Created by Аброрбек on 26.06.2023.
//

import UIKit

final class ToDoItemList: UIViewController {
    
    var list: [ToDoItem] = []
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
        
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
}

extension ToDoItemList: UITableViewDataSource, UITableViewDelegate{
    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        let deleteAction = UIContextualAction(style: .destructive, title: "") {
//            (action, sourceView, completionHandler) in
//
//            self.list.remove(at: indexPath.row)
//
//            completionHandler(true)
//        }
//
//        deleteAction.image = UIImage(systemName: "trash")
//
//        let editAction = UIContextualAction(style: .normal, title: "Изменить") {
//            (action, sourceView, completionHandler) in
//            // 1. Segue to Edit view MUST PASS INDEX PATH as Sender to the prepareSegue function
//            let vc = EditAttitudeViewController(header: Attitudes.attitudes[indexPath.row].header!, attitude: Attitudes.attitudes[indexPath.row].attitude!, counter: Int(Attitudes.attitudes[indexPath.row].counter), indexPath: indexPath.row)
//            vc.delegate = self
//            let nav = UINavigationController(rootViewController: vc)
//            nav.modalPresentationStyle = .fullScreen
//            self.present(nav, animated: true, completion: nil)
//            completionHandler(true)
//        }
//
//        editAction.image = UIImage(systemName: "pencil")
//        editAction.backgroundColor = .systemOrange
//        let swipeConfiguration = UISwipeActionsConfiguration(actions: [ deleteAction, editAction])
//        // Delete should not delete automatically
//        swipeConfiguration.performsFirstActionWithFullSwipe = false
//        return swipeConfiguration
//    }
//
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        <#code#>
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let counterViewController = CounterViewController(attitude: Attitudes.attitudes[indexPath.row].attitude!, header: Attitudes.attitudes[indexPath.row].header!, aim: Int(Attitudes.attitudes[indexPath.row].counter))
        navigationItem.backBarButtonItem?.title = ""
        navigationController?.pushViewController(counterViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let size = view.frame.height/10+10
        return CGFloat(size)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifier, for: indexPath) as?     CustomTableViewCell else {
                    return UITableViewCell()
                }
            cell.headerLabel.text = Attitudes.attitudes[indexPath.row].header
            cell.backgroundColor = .white
            cell.layer.cornerRadius = cell.frame.height/4.0
            cell.selectionStyle = .none
            return cell
        }
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffset = view.safeAreaInsets.bottom
        let offset = scrollView.contentOffset.y + defaultOffset
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
    }
}

