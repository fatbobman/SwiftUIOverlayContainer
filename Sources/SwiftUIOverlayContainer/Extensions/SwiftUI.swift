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

/// Pass nil to run body method  without animation.
public func disabledWithAnimation(_ animation: Animation? = .default, _ body: () -> Void) {
    if animation == nil {
        body()
    } else {
        withAnimation(animation) {
            body()
        }
    }
}

// some extension for condition
extension View {
    @ViewBuilder
    func `if`<V: View>(_ condition: @autoclosure () -> Bool, return result: (Self) -> V) -> some View {
        if condition() {
            result(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func `if`<V1: View, V2: View>(
        _ condition: @autoclosure () -> Bool,
        return result: (Self) -> V1,
        else elseResult: (Self) -> V2
    ) -> some View {
        if condition() {
            result(self)
        } else {
            elseResult(self)
        }
    }

    @ViewBuilder
    func ifNotNil<T, V>(_ value: T?, @ViewBuilder perform action: (Self, T) -> V) -> some View where V: View {
        if let value = value {
            action(self, value)
        } else {
            self
        }
    }
}
