//
//  SwiftUIView.swift
//
//
//  Created by Qiwei Li on 6/6/23.
//

import Combine
import SwiftUI

struct IntView: View {
    let label: String
    @Binding<Int> var number: Int
    @State var text: String

    init(label: String, number: Binding<Int>) {
        self.label = label
        self._text = .init(initialValue: String(number.wrappedValue))
        self._number = number
    }

    var body: some View {
        TextField(label, text: $text)
            .onReceive(Just(text)) { newValue in
                if let value = Int(newValue) {
                    text = newValue
                    self.number = value
                }
            }
    }
}
