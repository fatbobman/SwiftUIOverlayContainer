//
//  BackgroundStyle.swift
//
//
//  Created by Yang Xu on 2022/3/6
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation
import SwiftUI

/// The background Style for Container
public enum ContainerBackgroundStyle {
    case color(Color)
    case blur(Material)
    case view(AnyView)
    case none
}

extension ContainerBackgroundStyle {
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .color(let color):
            color
        case .blur(let material):
            Rectangle().fill(material)
        case .view(let view):
            view.allowsHitTesting(false) // disable interactivity of custom view
        case .none:
            EmptyView()
        }
    }

    /// Merge background style between container and container View
    ///
    /// When the type of Container is `Z-axis (z)`, each Container View can specify its own background style,
    /// and the priority is higher than the background style of Container.
    /// When Container type is `X-axis (x)` or `Y-axis (y)`, the background style of Container View will be ignored.
    ///
    ///     container         containerView          result
    ///       nil                nil                  empty
    ///       nil                none                 empty
    ///       nil                color                color
    ///       none               none                 empty
    ///       none               nil                  empty
    ///       color              blur                 blur
    ///       color(red)         color(blue)          color(blue)
    ///
    static func merge(containerBackgroundStyle: Self?, viewBackgroundStyle: Self?, containerType: ContainerType) -> Self {
        switch containerType {
        case .x, .y:
            return containerBackgroundStyle ?? .none
        case .z:
            guard let containerBackgroundStyle = containerBackgroundStyle else { return viewBackgroundStyle ?? .none }
            return viewBackgroundStyle ?? containerBackgroundStyle
        }
    }
}

/// define the background style
public extension ContainerBackgroundStyle {
    static let regularBlur = ContainerBackgroundStyle.blur(.regular)
        .view()
        .eraseToAnyView()
}
