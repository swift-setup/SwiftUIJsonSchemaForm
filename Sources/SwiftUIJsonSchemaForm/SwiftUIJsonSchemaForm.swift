import SwiftUI
import SwiftyJSON

public typealias OnUpdate = (JSON) -> Void

struct FormField: View {
    let schema: JSON
    let title: String
    let onUpdate: OnUpdate
    let key: String
    
    @State var stringValue: String
    @State var boolValue: Bool
    var values: JSON

    init(schema: JSON, values: JSON, keys: [String], onUpdate: @escaping OnUpdate) {
        let key = keys.last!
        
        self.values = values
        self.schema = schema
        self.title = schema["title"].string ?? key
        self.onUpdate = onUpdate
        self.key = key
        
        _stringValue = .init(initialValue: schema["default"].string ?? "")
        _boolValue = .init(initialValue: schema["default"].boolValue)
        
        if let value = values[key].string {
            _stringValue = .init(initialValue: value)
        }
        
        if let value = values[key].bool {
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
            onAppear()
        }
        .onChange(of: stringValue) { newValue in
            let v = values.debugDescription
            let newValues = updateValueHelper(value: newValue, key: key, values: values)
            onUpdate(newValues)
        }.onChange(of: boolValue) { newValue in
            let newValues = updateValueHelper(value: newValue, key: key, values: values)
            onUpdate(newValues)
        }
    }
    
    func onAppear() {
        switch schema["type"] {
            case "string", "number":
                let newValues = updateValueHelper(value: stringValue, key: key, values: values)
                onUpdate(newValues)
            case "boolean":
                let newValues = updateValueHelper(value: boolValue, key: key, values: values)
                onUpdate(newValues)
            default:
                break
        }
    }
}

public struct FormView: View {
    let jsonSchema: JSON
    let previousKey: String?
    var values: JSON
    let onUpdate: OnUpdate
    
    /**
     Creates a FormView using SwiftyJSON
     */
    public init(jsonSchema: JSON, values: JSON, onUpdate: @escaping OnUpdate) {
        self.jsonSchema = jsonSchema
        self.previousKey = nil
        self.onUpdate = onUpdate
        self.values = values
    }
    
    public var body: some View {
        Form {
            ForEach(jsonSchema["properties"].dictionaryValue.keys.sorted(), id: \.self) { key in
                FormField(schema: jsonSchema["properties"][key], values: values, keys: [key], onUpdate: onUpdate)
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
        """, values: JSON()) { _ in
        }

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
        """, values: ["c": "1111"]) { _ in
        }
    }
}
