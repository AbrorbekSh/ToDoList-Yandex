//
//  NSObject+Extension.swift
//  ToDoList
//
//  Created by Аброрбек on 26.06.2023.
//

import UIKit

extension NSObject {
    var className: String {
        return String(describing: self)
    }
}
