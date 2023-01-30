//
//  Modifiers.swift
//  Star Party
//
//  Created by Dakota Havel on 1/27/23.
//

import SwiftUI

struct TextFieldResetButton: ViewModifier {
    @Binding var text: String
    var defaultValue: String = ""

    func body(content: Content) -> some View {
        HStack {
            content

            if !text.isEmpty {
                Button(
                    action: { self.text = defaultValue },
                    label: {
                        Image(systemName: defaultValue.isEmpty ? "delete.left" : "arrow.counterclockwise.circle")
                            .foregroundColor(Color(UIColor.label))
                    }
                )
            }
        }
    }
}
