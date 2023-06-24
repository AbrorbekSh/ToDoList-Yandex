//
//  ViewController.swift
//  ToDoList
//
//  Created by Аброрбек on 10.06.2023.
//

import UIKit

final class ToDoItemDetails: UIViewController {
    
    //MARK: - Properties
    
    private let fileCacheService: FileCache
    private var isNew: Bool
    
    private var text: String?
    private var priority: Priority = .high
    private var deadline: Date?
    private var hexColor: String = "#000000"
    
    private var isCompleted: Bool?
    private var createdAt: Date = Date()
    
    private var toDoItem: ToDoItem? {
        didSet{
            textView.text = toDoItem?.text
            text = toDoItem?.text
            
            switch toDoItem?.priority {
            case .high:
                importanceView.segmentationControl.selectedSegmentIndex = 2
                priority = .high
            case .low:
                importanceView.segmentationControl.selectedSegmentIndex = 0
                priority = .low
            default:
                importanceView.segmentationControl.selectedSegmentIndex = 1
                priority = .basic
            }
            
            if let deadline = toDoItem?.deadline {
                self.deadline = deadline
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d MMMM yyyy"
                dateFormatter.locale = Locale(identifier: "ru")
                let formatedDate = dateFormatter.string(from: deadline)
                deadlineView.deadlineButton.setTitle(formatedDate, for: .normal)
                deadlineView.datePicker.date = deadline
                deadlineView.switchButton.isOn = true
                deadlineView.deadlineButton.isHidden = false
            }
            if let hex = toDoItem?.color {
                hexColor = hex
                colorButton.backgroundColor = UIColor(hexString: hex)
                textView.setTextColor(color: UIColor(hexString: hex))
            }
            
            if let createdAt = toDoItem?.createdAt {
                self.createdAt = createdAt
            }
        }
    }
    
    init(fileCacheService: FileCache, toDoItem: ToDoItem? = nil, isNew: Bool) {
        self.fileCacheService = fileCacheService
        self.toDoItem = toDoItem
        self.isNew = isNew
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        title = "Дело"
        
        let leftItem = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(leftItemTapped))
        let rightItem = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(rightItemTapped))

        self.navigationItem.leftBarButtonItem = leftItem
        self.navigationItem.rightBarButtonItem = rightItem
        
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
        viewControllerToPresent.delegate = self
        
        self.navigationController?.pushViewController(viewControllerToPresent, animated: true)
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
    
    @objc func deleteButtonPressed() {
        guard let id = toDoItem?.id else {
            return
        }
        fileCacheService.delete(id: id)
    }
    
    @objc func leftItemTapped() {
        // Handle left item tapped event
    }

    @objc func rightItemTapped() {
        if !isNew {
            guard
                let id = toDoItem?.id,
                let text = self.text
            else {
                return
            }
            let item = ToDoItem(
                id: id,
                text: text,
                priority: priority,
                deadline: self.deadline,
                createdAt: createdAt,
                editedAt: Date(),
                color: hexColor
            )
            
            fileCacheService.add(task: item)
        } else {
            guard
                let text = self.text
            else {
                return
            }
            let item = ToDoItem(
                text: text,
                priority: priority,
                deadline: self.deadline,
                createdAt: Date(),
                editedAt: Date(),
                color: hexColor
            )
            
            fileCacheService.add(task: item)
        }
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
        text = textView.text
    }
}

//MARK: - ColorPickerViewControllerDelegate

extension ToDoItemDetails: ColorPickerViewControllerDelegate {
    func finishChosingColor(colorHex: String) {
        colorButton.backgroundColor = UIColor(hexString: colorHex)
        textView.setTextColor(color: UIColor(hexString: colorHex))
        hexColor = colorHex
    }
}
