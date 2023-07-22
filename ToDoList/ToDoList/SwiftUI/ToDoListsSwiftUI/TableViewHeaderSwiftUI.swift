//
//  TableViewHeaderSwiftUI.swift
//  ToDoList
//
//  Created by Аброрбек on 18.07.2023.
//

import SwiftUI

protocol TableViewHeaderDelegate: AnyObject {
    var isFull: Bool { get }

    func getNumberOfItems() -> Int
    func showItemsByStatus()
}

struct TableViewHeaderSwiftUI: View {
    weak var delegate: (TableViewHeaderDelegate)?
    
    @State private var buttonTitle: String = "Скрыть"
    
    var body: some View {
        HStack {
            Text("Выполнено — \(delegate?.getNumberOfItems() ?? 0)")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
                .padding(EdgeInsets(top: 0, leading: -30, bottom: 0, trailing: 0))
            
            Spacer()
            
            Button(action: showButtonPressed) {
                Text(buttonTitle)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.blue)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: -30))
            }
        }
        .padding(.horizontal, 35)
    }
    
    private func showButtonPressed() {
        delegate?.showItemsByStatus()
        buttonTitle = delegate?.isFull ?? true ? "Скрыть" : "Показать"
    }
}
