//
//  DetailsViewSwiftUI.swift
//  ToDoList
//
//  Created by Аброрбек on 17.07.2023.
//

import SwiftUI

struct DetailsViewSwiftUI: View {
    
    var body: some View {
        NavigationView {
            VStack(spacing: Constants.ContenView.contentViewSpacing) {
                HStack() {
                    Spacer()
                    Button {
                        print("da")
                    } label: {
                        Text("Отменить")
                            .foregroundColor(.blue)
                    }

                
                    Spacer()
                    Text("Дело")
                        .font(.system(size: 17, weight: .bold))
                        .multilineTextAlignment(.center)
                    Spacer()
                    Button {
                        print("da")
                    } label: {
                        Text("Сохранить")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding(EdgeInsets(top: 10,
                                    leading: -20,
                                    bottom: 0,
                                    trailing: -20))
                ScrollView {
                    VStack(spacing: Constants.ContenView.contentViewSpacing) {

                        CustomTextEditor()
                            .background(Color.contentColor)
                            .frame(minHeight: 120)
                            .cornerRadius(16.0)

                        
                        DetailsSubviewSwiftUI()
                            .background(Color.contentColor)
                            .cornerRadius(16.0)
                        
                        Button {
                            print("da")
                        } label: {
                            Text("Удалить")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.red)
                                .frame(width: 350, height: 56)
                                .background(Color.contentColor)
                                .cornerRadius(Constants.radius)
                        }
                    }
                    .padding(.horizontal, Constants.horizontalMargin)
                    .padding(.top, Constants.ContenView.topAnchor)
                }
            }
            .navigationBarHidden(true)
            .background(Color.backgroundColor)
        }
    }

    private struct Constants {
        static let radius: CGFloat = 16.0
        static let horizontalMargin: CGFloat = 16.0
        
        enum ContenView {
            static let contentViewSpacing: CGFloat = 16.0
            static let topAnchor: CGFloat = 16.0
        }
    }
}

struct CustomTextEditor: View {
    
    @State private var text = "Что надо сделать?"

    var body: some View {
        TextEditor(text: $text)
            .foregroundColor(.gray.opacity(0.7))
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
    }
}

struct DetailsViewSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        DetailsViewSwiftUI()
    }
}
