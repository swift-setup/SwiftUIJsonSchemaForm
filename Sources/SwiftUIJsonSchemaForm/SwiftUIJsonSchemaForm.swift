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
        
        _stringValue = .init(initialValue: schema["default"].string ?? "")
        _boolValue = .init(initialValue: schema["default"].boolValue)
        
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
                    TextView(label: title, text: $stringValue, selections: schema["enum"].array?.map { v in
                        v.stringValue
                    })
                case "boolean":
                    Toggle(title, isOn: $boolValue)
                default:
                    Text("Unsupported type")
            }
        }
        .onAppear {
            // Set default value
            if let value = schema["default"].string {
                let newValues = updateValueHelper(value: JSON(rawValue: value)!, keys: keys, values: values)
                values = newValues
            }
            
            if let value = schema["default"].bool {
                let newValues = updateValueHelper(value: JSON(rawValue: value)!, keys: keys, values: values)
                values = newValues
            }
        }
        .onChange(of: stringValue) { newValue in
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
        self.previousKey = nil
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

struct JSONSchema_Previews: PreviewProvider {
    static var previews: some View {
        FormView(jsonSchema: """
        {
            "type": "object",
            "properties": {
                "a": {
                    "type": "string",
                    "title": "A",
                    "enum": ["A", "B", "C"]
                },
                "b": {
                    "type": "boolean",
                    "title": "B"
                },
                "c": {
                    "type": "string",
                    "title": "Hello world",
                    "default": "A"
                }
            }
        }
        """, values: .constant(JSON()))
    }
}
