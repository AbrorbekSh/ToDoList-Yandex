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
    
    private lazy var navBarContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        [
            leftBarButton,
            titleLabel,
            rightBarButton
        ].forEach { view.addSubview($0) }
        
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .center
        label.text = "Дело"
        return label
    }()
    
    private lazy var leftBarButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .contentFont
        
        return button
    }()
    
    private lazy var rightBarButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
        button.setTitle("Сохранить", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .contentFont
        
        return button
    }()
    
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
    
    private lazy var detailsSubview: DetailsSubview = {
        let view = DetailsSubview(viewModel: viewModel, view: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = .contentColor
        view.layer.cornerRadius = 16
        
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
        title = viewModel.title
        
        setupView()
        addSubviews()
        setupLayout()
    }
    
    private func setupViewModel(){
        viewModel.uploadData = { toDoItem in
            self.textView.text = toDoItem.text
            
            switch toDoItem.priority {
            case .important:
                self.detailsSubview.segmentationControl.selectedSegmentIndex = 2
            case .low:
                self.detailsSubview.segmentationControl.selectedSegmentIndex = 0
            default:
                self.detailsSubview.segmentationControl.selectedSegmentIndex = 1
            }
            
            if let deadline = toDoItem.deadline {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d MMMM yyyy"
                dateFormatter.locale = Locale(identifier: "ru")
                let formatedDate = dateFormatter.string(from: deadline)
                self.detailsSubview.deadlineButton.setTitle(formatedDate, for: .normal)
                self.detailsSubview.datePicker.date = deadline
                self.detailsSubview.switchButton.isOn = true
                self.detailsSubview.deadlineButton.isHidden = false
            }
            
            self.detailsSubview.colorButton.backgroundColor = UIColor(hexString: toDoItem.color)
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
        contentStackView.addArrangedSubview(detailsSubview)
        contentStackView.addArrangedSubview(deleteButton)
    }
    
    private func setupLayout(){
        NSLayoutConstraint.activate([
            navBarContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBarContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            navBarContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            navBarContainerView.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        NSLayoutConstraint.activate([
            leftBarButton.centerYAnchor.constraint(equalTo: navBarContainerView.centerYAnchor),
            leftBarButton.leadingAnchor.constraint(
                equalTo: navBarContainerView.leadingAnchor,
                constant: 16
            )
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: navBarContainerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: navBarContainerView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            rightBarButton.centerYAnchor.constraint(equalTo: navBarContainerView.centerYAnchor),
            rightBarButton.trailingAnchor.constraint(
                equalTo: navBarContainerView.trailingAnchor,
                constant: -16
            )
        ])
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalMargin),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalMargin),
            scrollView.topAnchor.constraint(equalTo: navBarContainerView.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.ContenView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
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
    
    //MARK: - Methods
    
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
        if !textView.text.isEmpty {
            viewModel.textDidChange(text: textView.text)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Что надо сделать?"
            textView.textColor = UIColor(hexString: viewModel.getColor())
        }
    }
}

//MARK: - ColorPickerViewControllerDelegate

extension ToDoItemDetailsViewController: ColorPickerViewControllerDelegate {
    func finishChosingColor(colorHex: String) {
        detailsSubview.colorButton.backgroundColor = UIColor(hexString: colorHex)
        textView.setTextColor(color: UIColor(hexString: colorHex))
        viewModel.colorDidChange(color: colorHex)
    }
}
