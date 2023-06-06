//
//  SwiftUIView.swift
//
//
//  Created by Qiwei Li on 6/6/23.
//

import SwiftUI

struct TextView: View {
    let label: String
    @Binding<String> var text: String
    let selections: [String]?

    init(label: String, text: Binding<String>) {
        self.label = label
        self._text = text
        self.selections = nil
    }

    init(label: String, text: Binding<String>, selections: [String]?) {
        self.label = label
        self._text = text
        self.selections = selections
    }

    var body: some View {
        if let selections = selections {
            Picker(label, selection: $text) {
                ForEach(selections, id: \.self) { selection in
                    Text(selection).tag(selection)
                }
            }
        } else {
            TextField(label, text: $text)
        }
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        TextView(label: "Hello", text: .constant("Hello world"), selections: ["Hello world", "B"])
    }
}
