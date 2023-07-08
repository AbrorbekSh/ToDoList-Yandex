//
//  AppColors.swift
//  ToDoList
//
//  Created by Аброрбек on 21.06.2023.
//

import UIKit

extension UIColor {
    static let contentColor = UIColor(named: "contentColor") ?? UIColor()
    static let textColor = UIColor(named: "textColor") ?? UIColor()
    static let backgroundColor = UIColor(named: "backgroundColor") ?? UIColor()
    static let switchBackgroundColor = UIColor(named: "switchBackgroundColor") ?? UIColor()
    static let switchSelectedColor = UIColor(named: "switchSelectedColor") ?? UIColor()
    
    static let gray = UIColor(hexString: "#000000").withAlphaComponent(0.2)
    
    static let systemBlue = UIColor(hexString: "#007AFF")
}
