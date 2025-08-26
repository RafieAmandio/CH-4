//
//  SwiftUIView.swift
//  CH-4
//
//  Created by Dwiki on 26/08/25.
//

import SwiftUI
import UIComponentsKit

struct CustomTextField: View {
    var label: String
    @Binding var text: String
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(AppFont.interSmallBold)
                .foregroundStyle(.black.opacity(0.6))
            TextField("", text: $text)
                .focused($isTextFieldFocused)
                .padding(10)
                .font(AppFont.inter14Regular)
                .frame(width: .infinity, height: 50, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 11)
                        .fill(AppColors.TextFieldBackground)

                )

        }
        .frame(maxWidth: .infinity, alignment: .topLeading)

    }
}

#Preview {
    CustomTextField(label: "name", text: .constant(""))
}
