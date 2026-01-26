//
//  AppStyles.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 26.01.2026.
//

import Foundation
import SwiftUI

struct AppTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding(14)
            .background(Color.white)
            .cornerRadius(8)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.appBorder, lineWidth: 1)
            }
    }
}
