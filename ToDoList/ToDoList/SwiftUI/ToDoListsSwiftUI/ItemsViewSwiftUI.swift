//
//  ItemsViewSwiftUI.swift
//  ToDoList
//
//  Created by Аброрбек on 16.07.2023.
//

import SwiftUI

struct ItemsViewSwiftUI: View {
    @ObservedObject var viewModel: ToDoItemListViewModel
    @State var viewDidLoad = false
    
    var body: some View {
            ZStack {
                List {
                    Section(header: TableViewHeaderSwiftUI(delegate: viewModel), content: {
                        ForEach(viewModel.filteredItems, id: \.id) { item in
                            HStack(spacing: 12) {
                                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(item.isCompleted ? .green : item.priority == .important ? .red : .gray.opacity(0.3))
                                    .background(Color.contentColor)
                                    .cornerRadius(10)
                                    .padding(.trailing, 8)
                                
                                VStack(alignment: .leading) {
                                    Text(item.priority == .important ? "‼️" + item.text : item.text)
                                        .font(.system(size: 18))
                                        .foregroundColor(item.isCompleted ? .gray.opacity(0.3) : .textColor)
                                        .lineLimit(3)
                                        .strikethrough(item.isCompleted ? true : false)
                                        .padding(.top, 5)
                                        .padding(.bottom, 4)
                                    
                                    HStack(spacing: 5) {
                                        if let deadline = item.deadline {
                                            Image(systemName: "calendar")
                                                .resizable()
                                                .frame(width: 12, height: 12)
                                                .foregroundColor(.gray)
                                                .background(Color.contentColor)
                                                .padding(.trailing, 2)
                                            
                                            Text(deadline, style: .date)
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                    }
                                }
                                arrowImageView
                            }
                            .swipeActions(edge: .leading) {
                                Button (action: { viewModel.markAsDone(item: item) }){
                                }
                                .tint(.green)
                            }
                            .swipeActions(edge: .trailing) {
                                Button (action: { viewModel.deleteItem(item: item) }){
                                    Image(systemName: "trash.fill")
                                }
                                .tint(.red)
                            }
                            .swipeActions(edge: .trailing) {
                                Button (action: { viewModel.openDetailsView(with: item)}){
                                    Image(systemName: "info.circle.fill")
                                }
                                .tint(.gray)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.openDetailsView(with: item)
                            }
                        }
                        Text("Новое")
                            .frame(height: 40)
                            .font(.system(size: 17))
                            .foregroundColor(.gray)
                            .padding(EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 200))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.addNewItemPressed()
                            }
                    })
                }
                .padding(EdgeInsets(top: 0, leading: -10, bottom: 0, trailing: -10))
                .listStyle(.insetGrouped)

                
                addButton
                    .frame(maxHeight: 600 ,alignment: .bottom)
            }
            .navigationTitle(viewModel.title)
            .onAppear(perform: {
                if viewDidLoad == false {
                    viewDidLoad = true
                    viewModel.viewDidLoad()
                }
                
            })
    }
    
    func delete(at offsets: IndexSet) {
        viewModel.filteredItems.remove(atOffsets: offsets)
    }
    
    private var arrowImageView: some View {
        Image(systemName: "chevron.forward")
            .foregroundColor(.gray.opacity(0.5))
            .frame(width: 12, height: 20)
    }
    
    private var newToDoItemCell: some View {
            Text("New Item")
    }
    
    private var addButton: some View {
        Button(action: viewModel.addNewItemPressed) {
                    Image(systemName: "plus")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)
                }
       }

}

struct ItemsViewSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ToDoItemListViewModel(fileCacheService: FileCacheService())
        ItemsViewSwiftUI(viewModel: viewModel)
    }
}

extension Color {
    static let contentColor = Color("contentColor")
    static let textColor = Color("textColor")
    static let backgroundColor = Color("backgroundColor")
    static let switchBackgroundColor = Color("switchBackgroundColor")
    static let switchSelectedColor = Color("switchSelectedColor")
    static let systemBlue = Color("#007AFF")
}
