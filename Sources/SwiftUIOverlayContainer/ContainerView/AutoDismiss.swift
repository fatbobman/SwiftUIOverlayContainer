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

/// Dismiss container view automatically
public enum ContainerViewAutoDismiss: Equatable {
    case seconds(TimeInterval)
    case disable
}

extension ContainerViewAutoDismiss {
    /// Merger the container's autoDismiss setting and the container view's autoDismiss setting
    ///
    /// The autoDismiss of container view configuration has higher priority than container configuration
    ///
    ///       container        view            result
    ///
    ///        nil             nil             disable
    ///        timeInterval    disable         disable
    ///        disable         timeInterval    timeInterval
    ///        timeIntervale   nil             timeInterval
    ///
    /// - Parameters:
    ///   - containerAutoDismiss: container's autoDismiss configuration
    ///   - viewAutoDismiss: containerView's autoDismiss configuration
    /// - Returns: ContainerViewAutoDismiss
    static func merge(containerAutoDismiss: Self?, viewAutoDismiss: Self?) -> Self {
        guard let containerAutoDismiss = containerAutoDismiss else { return viewAutoDismiss ?? Self.disable }
        return viewAutoDismiss ?? containerAutoDismiss
    }
}

extension View {
    /// Add auto dismiss feature to container View
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
    ///   - dismissAction: dismiss closure, include dismiss current view action and the disappearAction in the container configuration and container view configuration
    /// - Returns: A view that attaches a dismissed task
    @ViewBuilder
    func autoDismiss(_ type: ContainerViewAutoDismiss, dismissAction: @escaping DismissAction) -> some View {
        if case .seconds(let timeInterval) = type {
            self
                .task {
                    try? await Task.sleep(seconds: timeInterval)
                    if !Task.isCancelled {
                        await MainActor.run {
                            dismissAction()
                        }
                    }
                }
        } else {
            self
        }
    }
}
