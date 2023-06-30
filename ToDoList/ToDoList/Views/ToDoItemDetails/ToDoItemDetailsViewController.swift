//
//  ViewController.swift
//  ToDoList
//
//  Created by Аброрбек on 10.06.2023.
//

import UIKit

final class ToDoItemDetailsViewController: UIViewController {
    
    //MARK: - Properties
    
    private let viewModel: ToDoItemDetailsViewModel
    
    init(viewModel: ToDoItemDetailsViewModel) {
        self.viewModel = viewModel
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
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("Удалить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(.red, for: .normal)
        button.layer.cornerRadius = Constants.radius
        button.backgroundColor = UIColor.contentColor
        button.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var colorButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.backgroundColor = .black
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(colorButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupObservers()
        hideKeyboardWhenTappedAround()
        setup()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.viewWillDisappear()
    }
    
    //MARK: - Setup
    
    private func setup(){
        setupView()
        addSubviews()
        setupLayout()
        
        title = viewModel.title
        
        let leftItem = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(cancelPressed))
        let rightItem = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(savePressed))

        self.navigationItem.leftBarButtonItem = leftItem
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    private func setupViewModel(){
        viewModel.uploadData = { toDoItem in
            self.textView.text = toDoItem.text
            
            switch toDoItem.priority {
            case .high:
                self.importanceView.segmentationControl.selectedSegmentIndex = 2
            case .low:
                self.importanceView.segmentationControl.selectedSegmentIndex = 0
            default:
                self.importanceView.segmentationControl.selectedSegmentIndex = 1
            }
            
            if let deadline = toDoItem.deadline {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d MMMM yyyy"
                dateFormatter.locale = Locale(identifier: "ru")
                let formatedDate = dateFormatter.string(from: deadline)
                self.deadlineView.deadlineButton.setTitle(formatedDate, for: .normal)
                self.deadlineView.datePicker.date = deadline
                self.deadlineView.switchButton.isOn = true
                self.deadlineView.deadlineButton.isHidden = false
            }
            
            self.colorButton.backgroundColor = UIColor(hexString: toDoItem.color)
            self.textView.setTextColor(color: UIColor(hexString: toDoItem.color))
        }
    }
    
    private func setupView(){
        view.backgroundColor = UIColor.backgroundColor
    }
    
    private func addSubviews(){
        view.addSubview(navBarContainerView)
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
        
        NSLayoutConstraint.activate(
                    [
                        navBarContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                        navBarContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                        navBarContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                        navBarContainerView.heightAnchor.constraint(equalToConstant: 56)
                    ]
                )
        NSLayoutConstraint.activate(
            [
                leftBarButton.centerYAnchor.constraint(equalTo: navBarContainerView.centerYAnchor),
                leftBarButton.leadingAnchor.constraint(
                    equalTo: navBarContainerView.leadingAnchor,
                    constant: 16
                )
            ]
        )
        NSLayoutConstraint.activate(
            [
                titleLabel.centerXAnchor.constraint(equalTo: navBarContainerView.centerXAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: navBarContainerView.centerYAnchor)
            ]
        )
        NSLayoutConstraint.activate(
            [
                rightBarButton.centerYAnchor.constraint(equalTo: navBarContainerView.centerYAnchor),
                rightBarButton.trailingAnchor.constraint(
                    equalTo: navBarContainerView.trailingAnchor,
                    constant: -16
                )
            ]
        )
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalMargin),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalMargin),
            scrollView.topAnchor.constraint(equalTo: navBarContainerView.bottomAnchor),
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
    
    private lazy var navBarContainerView = makeNavBarContainerView()
    private lazy var titleLabel = makeTitleLabel()
    private lazy var leftBarButton = makeLeftBarButton()
    private lazy var rightBarButton = makeRightBarButton()
    
    private func makeNavBarContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        [
            leftBarButton,
            titleLabel,
            rightBarButton
        ].forEach { view.addSubview($0) }
        return view
    }
    
    private func makeLeftBarButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .contentFont
        return button
    }
    
    private func makeRightBarButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
        button.setTitle("Сохранить", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .contentFont
        return button
    }
    
    private func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .center
        label.text = "Дело"
        return label
    }
    
    @objc
    private func colorButtonPressed(){
        let viewControllerToPresent = ColorPickerViewController()
        viewControllerToPresent.delegate = self
        
        present(viewControllerToPresent, animated: true)
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
        viewModel.deleteButtonPressed()
    }
    
    @objc func cancelPressed() {
        viewModel.cancelPressed()
    }

    @objc func savePressed() {
        viewModel.savePressed()
    }
}

//MARK: - UITextViewDelegate

extension ToDoItemDetailsViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Что надо сделать?" {
            textView.text = nil
        }
        textView.textColor = UIColor(hexString: viewModel.getColor())
    }
    
    func textViewDidChange(_ textView: UITextView) {
        viewModel.textDidChange(text: textView.text)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Что надо сделать?"
            textView.textColor = UIColor.lightGray
        }
    }
}

//MARK: - ColorPickerViewControllerDelegate

extension ToDoItemDetailsViewController: ColorPickerViewControllerDelegate {
    
    func finishChosingColor(colorHex: String) {
        colorButton.backgroundColor = UIColor(hexString: colorHex)
        if textView.text != "Что надо сделать?" {
            textView.setTextColor(color: UIColor(hexString: colorHex))
        }
        viewModel.colorDidChange(color: colorHex)
    }
}
