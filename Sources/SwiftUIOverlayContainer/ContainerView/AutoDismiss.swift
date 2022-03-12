//
//  File.swift
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

/// dismiss container view automatic
public enum ContainerViewAutoDismiss: Equatable {
    case seconds(TimeInterval)
    case none
}

extension ContainerViewAutoDismiss {
    /// merger container autoDismiss and containerView autoDismiss
    ///
    ///       container        view            result
    ///        nil             nil             none
    ///        timeInterval    none            none
    ///        none            timeInterval    timeInterval
    ///        timeIntervale   nil             timeInterval
    ///
    /// - Parameters:
    ///   - containerAutoDismiss: container's autoDismiss configuration
    ///   - viewAutoDismiss: containerView's autoDismiss configuration
    /// - Returns: ContainerViewAutoDismiss
    static func merge(containerAutoDismiss: Self?, viewAutoDismiss: Self?) -> Self {
        guard let containerAutoDismiss = containerAutoDismiss else { return viewAutoDismiss ?? Self.none }
        return viewAutoDismiss ?? containerAutoDismiss
    }
}

extension View {
    /// add auto dismiss closure for container View
    ///
    ///      var autoDismiss: ContainerViewAutoDismiss {
    ///           ContainerViewAutoDismiss.merge(containerAutoDismiss: containerAutoDismiss,
    ///                                          viewAutoDismiss: viewAutoDismiss)
    ///      }
    ///
    ///      containerView
    ///         .autoDismiss(autoDismiss, dismissAction: some Action)
    ///
    ///
    /// - Parameters:
    ///   - type: ContainerViewAutoDismiss( the type of auto dismiss )
    ///   - dismissAction: dismiss closure. include container manager closure and specific dismiss closure
    /// - Returns: View with dismiss task
    @ViewBuilder
    func autoDismiss(_ type: ContainerViewAutoDismiss, dismissAction: @escaping DismissAction) -> some View {
        if case .seconds(let timeInterval) = type {
            self
                .task {
                    try? await Task.sleep(seconds: timeInterval)
                    if !Task.isCancelled {
                        dismissAction()
                    }
                }
        } else {
            self
        }
    }
}
