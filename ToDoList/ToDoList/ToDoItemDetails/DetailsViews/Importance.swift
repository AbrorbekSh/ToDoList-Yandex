//
//  Improtance.swift
//  ToDoList
//
//  Created by Аброрбек on 21.06.2023.
//

import UIKit

final class ImportanceView: UIView {
    
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
        self.addSubview(imporatanceLabel)
        self.addSubview(segmentationControl)
        self.addSubview(divider)
        segmentationControl.addTarget(self, action: #selector(segmentDidChange(_:)), for: .valueChanged)
        setupLayout()
    }
    
    private func setupLayout(){
        NSLayoutConstraint.activate([
            imporatanceLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -0.5),
            imporatanceLabel.heightAnchor.constraint(equalToConstant: 22),
            imporatanceLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
            
            segmentationControl.widthAnchor.constraint(equalToConstant: 150),
            segmentationControl.heightAnchor.constraint(equalToConstant: 36),
            segmentationControl.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -0.5),
            segmentationControl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            
            divider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            divider.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    private let imporatanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "Важность"
        label.font = Fonts.contentFont
        label.textColor = Colors.textColor
        label.sizeToFit()
        label.backgroundColor = Colors.contentColor
        label.layer.masksToBounds = true
        
        return label
    }()
    
    let segmentationControl: UISegmentedControl = {
        let items: [Any] = [Images.lowPriority, "нет", Images.highPriority]
        
        let segment = UISegmentedControl(items: items)
        segment.translatesAutoresizingMaskIntoConstraints = false
        
        segment.selectedSegmentTintColor = Colors.switchSelectedColor
        segment.backgroundColor = Colors.switchBackgroundColor
        segment.selectedSegmentIndex = 2
        
        return segment
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray
        
        return view
    }()
    
    @objc private func segmentDidChange(_ segmentationControl: UISegmentedControl){
//        switch segmentationControl.selectedSegmentIndex {
//        case 0:
//
//        case 1:
//
//        case 2:
//
//        default:
//
//        }
    }
    
}
