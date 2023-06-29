//
//  ToDoItemCell.swift
//  ToDoList
//
//  Created by Аброрбек on 26.06.2023.
//

import UIKit

final class ToDoItemListCell: UITableViewCell {
    
    static let identifier = String(describing: ToDoItemListCell.self)
    
    private let contentStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.spacing = 12
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .center
        
        
        return view
    }()
    
    private let textStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.spacing = 5
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .leading
        
        return view
    }()
    
    private let deadlineStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.spacing = 5
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.alignment = .center
        
        return view
    }()
    
    private var doneImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.contentColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        return imageView
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.backgroundColor = UIColor.contentColor
        label.textColor = UIColor.textColor
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var deadlineLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.backgroundColor = UIColor.contentColor
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var calendarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.calendar.withRenderingMode(.alwaysTemplate)
        imageView.backgroundColor = UIColor.contentColor
        imageView.tintColor = .black
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let arrowImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        
        image.image = UIImage(systemName: "chevron.forward")
        image.tintColor = .gray
        
        return image
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray
        
        return view
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.isUserInteractionEnabled = true
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionLabel.attributedText = .none
    }
    
    func configure(toDoItem: ToDoItem) {
        switch toDoItem.priority {
        case .high:
            descriptionLabel.text = "‼️" + toDoItem.text
        default:
            descriptionLabel.text = toDoItem.text
        }
        
        if let deadline = toDoItem.deadline {
            calendarImageView.isHidden = false
            deadlineLabel.isHidden = false
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM"
            deadlineLabel.text = dateFormatter.string(from: deadline)
        } else {
            calendarImageView.isHidden = true
            deadlineLabel.isHidden = true
        }
        
        
        if toDoItem.isCompleted {
            let config = UIImage.SymbolConfiguration(
                font: .boldSystemFont(ofSize: 20),
                scale: .large
            )
            doneImageView.image = UIImage(
                systemName: "checkmark.circle.fill",
                withConfiguration: config
            )
            doneImageView.tintColor = .green
            
            descriptionLabel.attributedText = NSAttributedString(
                string: descriptionLabel.text ?? " ",
                attributes: [
                    NSAttributedString.Key.strikethroughStyle:
                        NSUnderlineStyle.single.rawValue
                ]
            )
        } else {
            let config = UIImage.SymbolConfiguration(
                font: .boldSystemFont(ofSize: 20),
                scale: .large
            )
            doneImageView.image = UIImage(
                systemName: "circle",
                withConfiguration: config
            )
            
            switch toDoItem.priority {
            case .high:
                doneImageView.tintColor = .red
            default:
                doneImageView.tintColor = .lightGray
            }
        }
    }
    
    private func setup() {
        backgroundColor = UIColor.contentColor
        addSubviews()
        setConstraints()
    }
    
    private func addSubviews() {
        addSubview(contentStackView)
        addSubview(divider)
        contentStackView.addArrangedSubview(doneImageView)
        contentStackView.addArrangedSubview(textStackView)
        textStackView.addArrangedSubview(descriptionLabel)
        textStackView.addArrangedSubview(deadlineStackView)
        contentStackView.setCustomSpacing(16, after: descriptionLabel)
        contentStackView.addArrangedSubview(arrowImageView)
        deadlineStackView.addArrangedSubview(calendarImageView)
        deadlineStackView.addArrangedSubview(deadlineLabel)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 12
            ),
            contentStackView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            ),
            contentStackView.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -12
            ),
            contentStackView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -16
            )
        ])
        
        NSLayoutConstraint.activate([
            divider.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            divider.leadingAnchor.constraint(
                equalTo: textStackView.leadingAnchor
            ),
            divider.bottomAnchor.constraint(
                equalTo: bottomAnchor
            ),
            divider.heightAnchor.constraint(
                equalToConstant: 0.5
            )
        ])
        
        NSLayoutConstraint.activate([
            arrowImageView.widthAnchor.constraint(
                equalToConstant: 12
            ),
            arrowImageView.heightAnchor.constraint(
                equalToConstant: 20
            ),
            
        ])
    }
}
