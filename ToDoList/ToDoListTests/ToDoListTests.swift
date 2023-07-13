//
//  ToDoListTests.swift
//  ToDoListTests
//
//  Created by Аброрбек on 15.06.2023.
//

import XCTest
@testable import ToDoList

final class ToDoListTests: XCTestCase {
    
    //MARK: - Test sqlite
    
    let fileCache = FileCache()
    
    func testSQLite() {
        let item = makeFullToDoItem()
        fileCache.insert(item: item)
        
        let testItem = fileCache.load().first

        XCTAssertEqual(testItem, item)
        
        var size = fileCache.load().count
        XCTAssertEqual(size, 1)

        fileCache.delete(idx: item.id)
        
        size = fileCache.load().count
        XCTAssertEqual(size, 0)
    }
    
    //MARK: - Test struct
    
    func testDeadline() {
        let item = makeSimpleToDoItem()
        
        XCTAssertNil(item.deadline)
    }
    
    func testEditedAt() {
        let item = makeSimpleToDoItem()
        
        XCTAssertNil(item.editedAt)
    }
    
    func testIsCompleted() {
        let item = makeSimpleToDoItem()
        
        XCTAssertEqual(false, item.isCompleted)
    }
    
    func testID() {
        let fisrtItem = makeSimpleToDoItem()
        let secondItem = makeSimpleToDoItem()
        
        XCTAssertNotEqual(fisrtItem.id, secondItem.id)
    }
    
    //MARK: - Test JSON
    
    func testJSON(){
        let item = makeSimpleToDoItem()

        let json = item.json
        let testItem = ToDoItem.parse(json: json)

        XCTAssertEqual(testItem, item)
    }
    
    func testJSONFull(){
        let item = makeFullToDoItem()

        let json = item.json
        let testItem = ToDoItem.parse(json: json)

        XCTAssertEqual(testItem, item)
    }
    
    //MARK: - Test CSV
    
    func testCSV(){
        let item = makeSimpleToDoItem()

        let csv = item.csv
        let testItem = ToDoItem.parse(csv: csv)

        XCTAssertEqual(testItem, item)
    }
    
    func testCSVFull(){
        let item = makeFullToDoItem()

        let csv = item.csv
        let testItem = ToDoItem.parse(csv: csv)

        XCTAssertEqual(testItem, item)
    }
    
    //MARK: - Private methods
    
    private func makeSimpleToDoItem() -> ToDoItem {
        let item = ToDoItem(text: "testing",
                            priority: .basic,
                            createdAt: Date.now)
        return item
        
    }
    
    private func makeFullToDoItem() -> ToDoItem {
        let item = ToDoItem(
                            text: "testing",
                            priority: .low,
                            deadline: Date.now,
                            isCompleted: true,
                            createdAt: Date.now,
                            editedAt: Date.now,
                            color: "#FF453A"
        )
        return item
    }
}
