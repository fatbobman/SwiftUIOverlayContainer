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
///
/// 当 Container 的 type 为 z-axis时，每个 Container View都可以指定自己的 background，
/// 且优先级高于 Container 的 Background 设定。
/// 当 Container type 为 x-axis 或 y-axis 时，Container View 的 background 设定将被忽略。
///
///     container         containerView          result
///       nil                nil                  nil
///       nil                none                 empty
///       nil                color                color
///       none               none                 empty
///       none               nil                  empty
///       color              blur                 blur
///       color(red)         color(blue)          color(blue)
///
public enum ContainerBackgroundStyle {
    case color(Color)
    case blur(Material)
    case view(AnyView)
    case none
}

extension ContainerBackgroundStyle {
    @ViewBuilder
    func generateBackgroundView() -> some View {
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
}

/// define the background style
public extension ContainerBackgroundStyle {
    static let regularBlur = ContainerBackgroundStyle.blur(.regular)
}
