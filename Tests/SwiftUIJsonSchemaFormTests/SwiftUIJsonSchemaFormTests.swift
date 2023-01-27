import XCTest
@testable import SwiftUIJsonSchemaForm
import SwiftyJSON

final class SwiftUIJsonSchemaFormTests: XCTestCase {
    func testUpdateValues() throws {
        let values: JSON = [
            "a": "1",
            "b": "2",
            "c": [
                "d": "3"
            ]
        ]
        
        let newValues = updateValueHelper(value: "4", keys: ["a"], values: values)
        print("new: \(newValues.description)")
        XCTAssertEqual(newValues["a"], "4")
        XCTAssertEqual(newValues["b"], "2")
        XCTAssertEqual(newValues["c"]["d"], "3")
    }
    
    func testUpdateValues2() throws {
        let values: JSON = [
            "a": "1",
            "b": "2",
            "c": [
                "d": "3"
            ]
        ]
        
        let newValues = updateValueHelper(value: "4", keys: ["c", "d"], values: values)
        XCTAssertEqual(newValues["a"], "1")
        XCTAssertEqual(newValues["b"], "2")
        XCTAssertEqual(newValues["c"]["d"], "4")
    }
}
