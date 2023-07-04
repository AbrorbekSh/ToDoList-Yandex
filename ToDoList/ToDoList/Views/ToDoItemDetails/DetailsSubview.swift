//
//  DetailsSubview.swift
//  ToDoList
//
//  Created by Аброрбек on 04.07.2023.
//

import UIKit

final class DetailsSubview: UIView {
    
    private let viewModel: ToDoItemDetailsViewModel
    private let view: ToDoItemDetailsViewController
    
    //MARK: -LifeCycle
    
    init(viewModel: ToDoItemDetailsViewModel, view: ToDoItemDetailsViewController){
        self.viewModel = viewModel
        self.view = view
        super.init(frame: .zero)
        
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup
    
    private func setupView(){
        self.backgroundColor = UIColor.contentColor
        
        self.addSubview(contentStackView)
        
        importanceStackView.addArrangedSubview(imporatanceLabel)
        importanceStackView.addArrangedSubview(segmentationControl)
        
        contentStackView.addArrangedSubview(importanceStackView)
        contentStackView.addArrangedSubview(divider1)
        
        colorStackView.addArrangedSubview(colorLabel)
        colorStackView.addArrangedSubview(colorButton)
        
        contentStackView.addArrangedSubview(colorStackView)
        contentStackView.addArrangedSubview(divider2)
        
        labelsStackView.addArrangedSubview(deadlineLabel)
        labelsStackView.addArrangedSubview(deadlineButton)
        
        deadlineStackView.addArrangedSubview(labelsStackView)
        deadlineStackView.addArrangedSubview(switchButton)
        
        contentStackView.addArrangedSubview(deadlineStackView)
        contentStackView.addArrangedSubview(divider3)
        contentStackView.addArrangedSubview(datePicker)
        
        setupLayout()
    }
    
    private func setupLayout(){
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
            ),
        ])
        
        NSLayoutConstraint.activate([
            segmentationControl.heightAnchor.constraint(equalToConstant: 36),
            
            divider1.heightAnchor.constraint(equalToConstant: 2 / UIScreen.main.scale),
            divider2.heightAnchor.constraint(equalToConstant: 2 / UIScreen.main.scale),
            divider3.heightAnchor.constraint(equalToConstant: 2 / UIScreen.main.scale),
            
            colorButton.heightAnchor.constraint(equalToConstant: 35),
            colorButton.widthAnchor.constraint(equalToConstant: 35),
        ])
    }
    
    private let contentStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.spacing = 10
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .fill
        
        return view
    }()
    
    private let importanceStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.spacing = 16
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.alignment = .center
        
        return view
    }()
    
    private let imporatanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "Важность"
        label.font = UIFont.contentFont
        label.textColor = UIColor.textColor
        label.sizeToFit()
        label.backgroundColor = UIColor.contentColor
        label.layer.masksToBounds = false
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var segmentationControl: UISegmentedControl = {
        let items: [Any] = [UIImage.lowPriority, "нет", UIImage.highPriority]
        
        let segment = UISegmentedControl(items: items)
        segment.translatesAutoresizingMaskIntoConstraints = false
        
        segment.selectedSegmentTintColor = UIColor.switchSelectedColor
        segment.backgroundColor = UIColor.switchBackgroundColor
        segment.selectedSegmentIndex = 1
        segment.addTarget(self, action: #selector(segmentDidChange(_:)), for: .valueChanged)
        
        return segment
    }()
    
    private let divider1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        
        return view
    }()
    
    private let colorStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.spacing = 16
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .center
        
        return view
    }()
    
    private let colorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "Выбрать цвет"
        label.font = UIFont.contentFont
        label.textColor = UIColor.textColor
        label.sizeToFit()
        label.backgroundColor = UIColor.contentColor
        label.layer.masksToBounds = true
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var colorButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.backgroundColor = .black
        button.layer.cornerRadius = 35/2
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(colorButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    private let divider2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        
        return view
    }()
    
    private let deadlineStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.spacing = 16
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .center
        
        return view
    }()
    
    private let labelsStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.spacing = 0
        view.axis = .vertical
        view.distribution = .fillEqually
        view.alignment = .leading
        
        return view
    }()
    
    private let deadlineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "Сделать до"
        label.font = UIFont.contentFont
        label.textColor = UIColor.textColor
        label.sizeToFit()
        label.backgroundColor = UIColor.contentColor
        label.layer.masksToBounds = true
        
        return label
    }()
    
    lazy var deadlineButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "ru")
        let date = Date.nextDay
        let formatedDate = dateFormatter.string(from: date)

        button.setTitle(formatedDate, for: .normal)
        button.titleLabel?.font = UIFont.chooseDeadlineFont
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.backgroundColor = UIColor.contentColor
        button.isHidden = true
        
        button.addTarget(self, action: #selector(deadlineButtonPressed), for: .touchUpInside)

        return button
    }()
    
    lazy var switchButton: UISwitch = {
        let button = UISwitch()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(
            self,
            action: #selector(didValueChanged),
            for: .valueChanged
        )
        
        return button
    }()
    
    private let divider3: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        view.isHidden = true
        
        return view
    }()
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.backgroundColor = UIColor.contentColor
        datePicker.timeZone = .autoupdatingCurrent
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        datePicker.date = Date.nextDay
        datePicker.isHidden = true
        datePicker.addTarget(self, action: #selector(onDateValueChanged(_:)), for: .valueChanged)

        
        return datePicker
    }()
    
    @objc
    private func didValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            deadlineButton.isHidden = false
            let date = datePicker.date
            viewModel.deadlineDidChange(deadline: date)
        } else {
            UIView.animate(withDuration: 0.3) { [self] in
                deadlineButton.isHidden = true
                divider3.isHidden = true
                datePicker.isHidden = true
            }
        }
    }
    
    @objc
    private func colorButtonPressed(){
        let viewControllerToPresent = ColorPickerViewController()
        viewControllerToPresent.delegate = view

        view.present(viewControllerToPresent, animated: true)
    }
    
    @objc
    private func onDateValueChanged(_ datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "ru")
        let date = datePicker.date
        let formatedDate = dateFormatter.string(from: date)
        deadlineButton.setTitle(formatedDate, for: .normal)
        UIView.animate(withDuration: 0.3) {
            self.divider3.isHidden = true
            self.datePicker.isHidden = true
        }
        viewModel.deadlineDidChange(deadline: date)
    }
    
    @objc
    private func deadlineButtonPressed(){
        UIView.animate(withDuration: 0.3) { [self] in
            divider3.isHidden = false
            datePicker.isHidden = false
        }
    }
    
    @objc private func segmentDidChange(_ segmentationControl: UISegmentedControl){
        switch segmentationControl.selectedSegmentIndex {
        case 0:
            viewModel.priorityDidChange(priority: .low)
        case 2:
            viewModel.priorityDidChange(priority: .high)
        default:
            viewModel.priorityDidChange(priority: .basic)
        }
    }
}
