//
//  NewToDoItemCell.swift
//  ToDoList
//
//  Created by Аброрбек on 28.06.2023.
//

import UIKit

final class NewToDoItemCell: UITableViewCell {

    static let identifier = String(describing: NewToDoItemCell.self)
    
    private var newLabel: UILabel = {
        let label = UILabel()
        label.text = "Новое"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.isUserInteractionEnabled = true
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .contentColor
        addSubview(newLabel)
        selectionStyle = .none
        
        NSLayoutConstraint.activate([
            newLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 55
            ),
            newLabel.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 20
            ),
            newLabel.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -20
            ),
            newLabel.heightAnchor.constraint(
                equalToConstant: 15
            )
        ])
    }
}
