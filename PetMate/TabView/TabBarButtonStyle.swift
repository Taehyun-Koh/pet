//
//  TabBarButtonStyle.swift
//  PetMate
//
//  Created by 고태현 on 2023/03/16.
//

import Foundation
import SwiftUI

struct TabBarButtonStyle : ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .scaleEffect(configuration.isPressed ? 0.6 : 1)
//            .animation(.spring(), value: configuration.isPressed)
    }
}
