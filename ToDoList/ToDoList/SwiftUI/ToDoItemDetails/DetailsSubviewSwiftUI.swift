//
//  DetailsSubviewSwiftUI.swift
//  ToDoList
//
//  Created by Аброрбек on 17.07.2023.
//

import SwiftUI

struct DetailsSubviewSwiftUI: View {
    
    @State var selection: Int = 0
    @State var isOn: Bool = true
    @State var selectedDate: Date = Date()
    
    var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 16) {
                HStack() {
                    Text("Важность")
                        .font(.system(size: 17))
                        .foregroundColor(.textColor)
                    Spacer()
                    Picker("", selection: $selection) {
                        Image("lowPriority")
                            .tag(Priority.basic)
                        Text("нет")
                            .tag(Priority.low)
                        Image("highPriority")
                            .tag(Priority.basic)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 150, height: 36)
                    .background(Color.switchBackgroundColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.vertical, 8)
                .background(Color.contentColor)

            }
            .padding(.horizontal, 16)
            
            Divider()
                .background(Color.gray.opacity(0.3))
                .frame(height: 0.5)
                .padding(.horizontal, 20)
            
            VStack {
                HStack {
                    Text("Выбрать цвет")
                        .font(.system(size: 17))
                        .foregroundColor(.textColor)
                    Spacer()
                    ColorButton(color: Color(.black))
                        .padding(.trailing, 20)
                }
                .padding(.vertical, 8)
                .background(Color.contentColor)
            }
            .padding(.horizontal, 16)
            
            Divider()
                .background(Color.gray.opacity(0.3))
                .frame(height: 0.5)
                .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                HStack {
                    VStack(spacing: 10) {
                        Text("Сделать до")
                            .font(.system(size: 17))
                            .foregroundColor(.textColor)
                        
                        Text("29 июля 2023")
                            .font(.system(size: 13))
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    Toggle("", isOn: $isOn)
                        .frame(width: 50, height: 30)
                        .padding(.trailing, 20)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.contentColor)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .frame(height: 0.5)
                    .padding(.horizontal, 20)
                
                DatePicker("Select a Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .background(Color.contentColor)
                    .padding(.horizontal, 16)
                    .environment(\.locale, Locale(identifier: "ru"))
        }
        .background(Color.contentColor)
        }
    }
}

struct ColorButton: View {
    var color: Color
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 35, height: 35)
            .overlay(
                Circle()
                    .stroke(Color.black, lineWidth: 1)
            )
    }
}

struct DetailsSubviewSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        DetailsSubviewSwiftUI()
    }
}
