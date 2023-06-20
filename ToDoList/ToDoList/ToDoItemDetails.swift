//
//  ViewController.swift
//  ToDoList
//
//  Created by Аброрбек on 10.06.2023.
//

import UIKit

final class ToDoItemDetails: UIViewController {
    
    //MARK: - Properties
    
    var toDoItem: ToDoItem?
    
    private enum Constants {
        static let radius = 16.0
        static let horizontalMargin = 16.0
        static let elementsColor = UIColor.white
        
        enum ContenView {
            static let contentViewSpacing = 16.0
            static let topAnchor = 16.0
        }
        
    }
    
    //MARK: - UI Elelements
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        
        return scroll
    }()
    
    private let contentStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.axis = .vertical
        view.spacing = Constants.ContenView.contentViewSpacing
        view.distribution = .fill
        
        return view
    }()
    
    private lazy var textView: CustomTextView = {
        let textView = CustomTextView(delegate: self)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.layer.cornerRadius = Constants.radius
  
        return textView
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .singleLine
        table.layer.cornerRadius = Constants.radius
        table.backgroundColor = Constants.elementsColor
        
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return table
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("Удалить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(rawValue: 400))
        button.setTitleColor(.red, for: .normal)
        button.layer.cornerRadius = Constants.radius
        button.backgroundColor = Constants.elementsColor
        
        return button
    }()
    
    
    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() //extension
        setup()
    }
    
    //MARK: - Setup
    
    private func setup(){
        setupView()
        addSubviews()
        setupLayout()
    }
    
    private func setupView(){
//        view.backgroundColor = UIColor(hexString: "#F7F6F2")
        view.backgroundColor = .black
    }
    
    private func addSubviews(){
        view.addSubview(scrollView)

        scrollView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(textView)
        contentStackView.addArrangedSubview(tableView)
        contentStackView.addArrangedSubview(deleteButton)
    }
    
    private func setupLayout(){
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalMargin),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalMargin),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.ContenView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -2 * Constants.horizontalMargin),
            
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            deleteButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
}

extension ToDoItemDetails: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Что надо сделать?"
            textView.textColor = UIColor.lightGray
        }
    }
}

