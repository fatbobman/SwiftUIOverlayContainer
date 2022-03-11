//
//  SwiftUI.swift
//
//
//  Created by Yang Xu on 2022/3/7
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation
import SwiftUI

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

/// Pass nil to run body with animation.
public func disabledWithAnimation(_ animation: Animation? = .default, _ body: () -> Void) {
    if animation == nil {
        body()
    } else {
        withAnimation(animation) {
            body()
        }
    }
}
