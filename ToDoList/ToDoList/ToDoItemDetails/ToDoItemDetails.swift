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
        scroll.alwaysBounceVertical = true
        
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
    
    private let importanceView: ImportanceView = {
        let view = ImportanceView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.cornerRadius = Constants.radius
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        return view
    }()
    
    private let deadlineView: DeadlineView = {
        let view = DeadlineView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.cornerRadius = Constants.radius
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        return view
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("Удалить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(.red, for: .normal)
        button.layer.cornerRadius = Constants.radius
        button.backgroundColor = Colors.contentColor
        
        return button
    }()
    
    
    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
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
        view.backgroundColor = Colors.backgroundColor
    }
    
    private func addSubviews(){
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(textView)
        contentStackView.addArrangedSubview(importanceView)
        importanceView.addSubview(colorButton)
        contentStackView.setCustomSpacing(0, after: importanceView)
        contentStackView.addArrangedSubview(deadlineView)
        contentStackView.addArrangedSubview(deleteButton)
    }
    
    private func setupLayout(){
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalMargin),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalMargin),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.ContenView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            importanceView.heightAnchor.constraint(equalToConstant: 56),
            
            colorButton.centerXAnchor.constraint(equalTo: importanceView.centerXAnchor, constant: -10),
            colorButton.centerYAnchor.constraint(equalTo: importanceView.centerYAnchor),
            colorButton.heightAnchor.constraint(equalToConstant: 30),
            colorButton.widthAnchor.constraint(equalToConstant: 30),
            
            deadlineView.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
            
            deleteButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private lazy var colorButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.backgroundColor = .black
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(colorButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    @objc
    private func colorButtonPressed(){
        let viewControllerToPresent = ColorPickerViewController()
        viewControllerToPresent.modalPresentationStyle = .popover

        present(viewControllerToPresent, animated: true, completion: nil)
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            adjustScrollViewContentInset(with: keyboardHeight)
        }
    }

    @objc
    private func keyboardWillHide(notification: NSNotification) {
        adjustScrollViewContentInset(with: 0.0)
    }
    
    func adjustScrollViewContentInset(with keyboardHeight: CGFloat) {
        scrollView.contentInset.bottom = keyboardHeight
    }
}

//MARK: - UITextViewDelegate

extension ToDoItemDetails: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = Colors.textColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Что надо сделать?"
            textView.textColor = UIColor.lightGray
        }
    }
}
