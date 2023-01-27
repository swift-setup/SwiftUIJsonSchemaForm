import SwiftUI
import SwiftyJSON

struct FormField: View {
    let keys: [String]
    let schema: JSON
    let title: String
    
    @State var stringValue: String
    @State var boolValue: Bool
    @Binding var values: JSON
    
    init(schema: JSON, values: Binding<JSON>, keys: [String]) {
        let key = keys.last!
        
        self._values = values
        self.schema = schema
        self.keys = keys
        self.title = schema["title"].string ?? key
        
        _stringValue = .init(initialValue: "")
        _boolValue = .init(initialValue: false)
        
        if let value = schema[key].string {
            _stringValue = .init(initialValue: value)
        }
        
        if let value = schema[key].bool {
            _boolValue = .init(initialValue: value)
        }
    }
    
    var body: some View {
        Group {
            switch schema["type"] {
                case "string", "number":
                    TextField(title, text: $stringValue)
                case "boolean":
                    Toggle(title, isOn: $boolValue)
            default:
                Text("Unsupported type")
            }
        }.onChange(of: stringValue) { newValue in
            let newValues = updateValueHelper(value: JSON(rawValue: newValue)!, keys: keys, values: values)
            values = newValues
        }.onChange(of: boolValue) { newValue in
            let newValues = updateValueHelper(value: JSON(rawValue: newValue)!, keys: keys, values: values)
            values = newValues
        }
    }
}

public struct FormView: View {
    let jsonSchema: JSON
    let previousKey: String?
    @Binding var values: JSON
    
    /**
     Creates a FormView using SwiftyJSON
     */
    public init(jsonSchema: JSON, values: Binding<JSON>) {
        self.jsonSchema = jsonSchema
        self._values = values
        previousKey = nil
    }
    
    /**
     Creates a FormView using data
     */
    public init(jsonSchema: Data, values: Binding<JSON>) {
        self.previousKey = nil
        self.jsonSchema = try! JSON(data: jsonSchema)
        self._values = values
    }
    
    /**
     Creates a FormView using json string
     */
    public init(jsonSchema: String, values: Binding<JSON>) {
        self.previousKey = nil
        self.jsonSchema = JSON(parseJSON: jsonSchema)
        self._values = values
    }
    
    public var body: some View {
        Form {
            ForEach(jsonSchema["properties"].dictionaryValue.keys.sorted(), id: \.self) { key in
                FormField(schema: jsonSchema["properties"][key], values: $values, keys: [key])
            }
        }
    }
}


