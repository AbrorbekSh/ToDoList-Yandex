//
//  Date+Extension.swift
//  ToDoList
//
//  Created by Аброрбек on 22.06.2023.
//

import Foundation

extension Date {
    static var nextDay: Date {
        let secondsPerDay: TimeInterval = 86_400
        return Date().addingTimeInterval(secondsPerDay)
    }
}
