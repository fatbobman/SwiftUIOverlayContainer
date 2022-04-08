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
// swiftlint:disable large_tuple

import Foundation
import SwiftUI

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
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

extension View {
    @available(iOS, introduced: 14, obsoleted: 15)
    @available(macOS, introduced: 11, obsoleted: 12)
    func task(priority: TaskPriority = .userInitiated, _ action: @escaping @Sendable () async -> Void) -> some View {
        self
            .onAppear {
                Task(priority: priority) {
                    await action()
                }
            }
    }
}

// Convenience extension to monitor multiple properties at the same time
extension View {
    func onChange<X, Y>(of value1: X,
                        _ value2: Y,
                        perform action: @escaping (_ newValues: (X, Y)) -> Void)
        -> some View where X: Equatable, Y: Equatable {
        self
            .onChange(of: value1, perform: { newValue1 in action((newValue1, value2)) })
            .onChange(of: value2, perform: { newValue2 in action((value1, newValue2)) })
    }

    func onChange<X, Y, Z>(of value1: X,
                           _ value2: Y,
                           _ value3: Z,
                           perform action: @escaping (_ newValues: (X, Y, Z)) -> Void)
        -> some View where X: Equatable, Y: Equatable, Z: Equatable {
        self
            .onChange(of: value1, perform: { newValue1 in action((newValue1, value2, value3)) })
            .onChange(of: value2, perform: { newValue2 in action((value1, newValue2, value3)) })
            .onChange(of: value3, perform: { newValue3 in action((value1, value2, newValue3)) })
    }

    func onChange<C0, C1, C2, C3>(of value1: C0,
                                  _ value2: C1,
                                  _ value3: C2,
                                  _ value4: C3,
                                  perform action: @escaping (_ newValues: (C0, C1, C2, C3)) -> Void)
        -> some View where C0: Equatable, C1: Equatable, C2: Equatable, C3: Equatable {
        self
            .onChange(of: value1, perform: { newValue1 in action((newValue1, value2, value3, value4)) })
            .onChange(of: value2, perform: { newValue2 in action((value1, newValue2, value3, value4)) })
            .onChange(of: value3, perform: { newValue3 in action((value1, value2, newValue3, value4)) })
            .onChange(of: value4, perform: { newValue4 in action((value1, value2, value3, newValue4)) })
    }
}

extension View {
    /// condition clip
    @ViewBuilder
    func clipped(enable: Bool) -> some View {
        if enable {
            clipped()
        } else {
            self
        }
    }

    /// condition ignoresSafeArea
    @ViewBuilder
    func ignoresSafeArea(type: ContainerIgnoresSafeArea) -> some View {
        switch type {
        case .disable:
            self
        case .all:
            ignoresSafeArea()
        case .custom(let regions, let edges):
            ignoresSafeArea(regions, edges: edges)
        }
    }

    /// set zIndex by timeStamp of indentifiableView
    func zIndex(timeStamp: Date, order: ContainerDisplayOrder) -> some View {
        var index = timeStamp.timeIntervalSince1970
        if case .descending = order {
            index = Date.distantFuture.timeIntervalSince1970 - index
        }
        return zIndex(index)
    }
}
