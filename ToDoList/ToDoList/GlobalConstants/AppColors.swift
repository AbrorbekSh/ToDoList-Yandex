//
//  AppColors.swift
//  ToDoList
//
//  Created by Аброрбек on 21.06.2023.
//

import UIKit

final class Colors {
    
//    switch traitCollection.userInterfaceStyle {
//    case .light:
//        static let contentColor = UIColor.white
//        static let textColor = UIColor.black
//        static let backgroundColor = UIColor(hexString: "#F2F2F7")
//        static let gray = UIColor(hexString: "#000000").withAlphaComponent(0.2)
//        static let systemBlue = UIColor(hexString: "#007AFF")
//    case .dark:
//        static let contentColor = UIColor.white
//        static let textColor = UIColor.black
//        static let backgroundColor = UIColor(hexString: "#F2F2F7")
//        static let gray = UIColor(hexString: "#000000").withAlphaComponent(0.2)
//        static let systemBlue = UIColor(hexString: "#007AFF")
//    default:
//        break
//    }
    
    static let contentColor = UIColor(named: "contentColor") ?? UIColor()
    static let textColor = UIColor(named: "textColor") ?? UIColor()
    static let backgroundColor = UIColor(named: "backgroundColor") ?? UIColor()
    static let switchBackgroundColor = UIColor(named: "switchBackgroundColor") ?? UIColor()
    static let switchSelectedColor = UIColor(named: "switchSelectedColor") ?? UIColor()
    
    static let gray = UIColor(hexString: "#000000").withAlphaComponent(0.2)
    
    static let systemBlue = UIColor(hexString: "#007AFF")
}
