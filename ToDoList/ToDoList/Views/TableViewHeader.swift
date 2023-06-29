//
//  TableViewHeader.swift
//  ToDoList
//
//  Created by Аброрбек on 29.06.2023.
//

import UIKit

final class TableViewHeader: UITableViewHeaderFooterView {
    
    static let identifier = String(describing: TableViewHeader.self)
    
    private let labelsStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.spacing = 16
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.alignment = .leading
        
        return view
    }()
    
    private let completedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "Выполнено — 5"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .lightGray
        
        label.backgroundColor = .backgroundColor
        
        return label
    }()
    
    private let showButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("    Показать", for: .normal)
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = .backgroundColor
        
        return button
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(){
        addSubview(labelsStackView)
        labelsStackView.addArrangedSubview(completedLabel)
        labelsStackView.addArrangedSubview(showButton)
        setupLayout()
    }
    
    //MARK: - Layout
    
    private func setupLayout(){
        NSLayoutConstraint.activate([
            labelsStackView.topAnchor.constraint(
                equalTo: topAnchor
            ),
            labelsStackView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 35
            ),
            labelsStackView.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            labelsStackView.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -12
            ),
        ])
    }
    
}
