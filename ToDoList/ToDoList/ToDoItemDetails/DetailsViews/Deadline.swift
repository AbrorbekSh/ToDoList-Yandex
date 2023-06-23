//
//  Deadline.swift
//  ToDoList
//
//  Created by Аброрбек on 21.06.2023.
//

import UIKit

final class DeadlineView: UIView {
    
    //MARK: -LifeCycle
    
    init(){
        super.init(frame: .zero)
        
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup
    
    private func setupView(){
        self.backgroundColor = Colors.contentColor
        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(deadlineButton)
        contentStackView.addArrangedSubview(labelsStackView)
        contentStackView.addArrangedSubview(divider)
        contentStackView.addArrangedSubview(datePicker)
        
        self.addSubview(contentStackView)
        self.addSubview(switchButton)
        
        setupLayout()
    }
    
    private func setupLayout(){
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            contentStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -12),
            contentStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            labelsStackView.widthAnchor.constraint(equalToConstant: 150),
            labelsStackView.heightAnchor.constraint(equalToConstant: 44),
            
            divider.heightAnchor.constraint(equalToConstant: 0.5),
            divider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            datePicker.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            datePicker.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            
            switchButton.widthAnchor.constraint(equalToConstant: 51),
            switchButton.heightAnchor.constraint(equalToConstant: 31),
            switchButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 13.5),
            switchButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
        ])
    }
    
    private let labelsStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.spacing = 0
        view.axis = .vertical
        view.distribution = .fillEqually
        view.alignment = .leading
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "Сделать до"
        label.font = Fonts.contentFont
        label.textColor = Colors.textColor
        label.sizeToFit()
        label.backgroundColor = Colors.contentColor
        label.layer.masksToBounds = true
        
        return label
    }()
    
    private lazy var deadlineButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "ru")
        let date = Date.nextDay
        let formatedDate = dateFormatter.string(from: date)

        button.setTitle(formatedDate, for: .normal)
        button.titleLabel?.font = Fonts.chooseDeadlineFont
        button.setTitleColor(Colors.systemBlue, for: .normal)
        button.backgroundColor = Colors.contentColor
        button.isHidden = true
        
        button.addTarget(self, action: #selector(deadlineButtonPressed), for: .touchUpInside)

        return button
    }()
    
    private lazy var switchButton: UISwitch = {
        let button = UISwitch()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(
            self,
            action: #selector(didValueChanged),
            for: .valueChanged
        )
        
        return button
    }()
    
    private let contentStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.spacing = 9
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.alignment = .leading
        
        return view
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray
        view.isHidden = true
        
        return view
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.backgroundColor = Colors.contentColor
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
        print("da")
        if sender.isOn {
            print("da")
            deadlineButton.isHidden = false
//            divider.isHidden = false
//            UIView.animate(withDuration: 0.3) { [self] in
//                deadlineButton.isHidden = false
//                datePicker.isHidden = false
//            }
        } else {
            divider.isHidden = true
            deadlineButton.isHidden = true
            UIView.animate(withDuration: 0.3) { [self] in
                datePicker.isHidden = true
            }
        }
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
            self.divider.isHidden = true
            self.datePicker.isHidden = true
        }
    }
    
    @objc
    private func deadlineButtonPressed(){
        UIView.animate(withDuration: 0.3) { [self] in
            divider.isHidden = false
            datePicker.isHidden = false
        }
    }
}
