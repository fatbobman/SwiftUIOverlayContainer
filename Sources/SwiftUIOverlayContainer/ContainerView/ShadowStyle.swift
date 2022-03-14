//
//  ShadowStyle.swift
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

/// The shadow style of container view
public enum ContainerViewShadowStyle {
    /// This option corresponds to `.shadow(radius:CGFloat)` modifier
    case radius(CGFloat)
    /// This option corresponds to `.shadow(color: color, radius: radius, x: x, y: y)` modifier
    case custom(Color, CGFloat, CGFloat, CGFloat)
    /// No shadow style
    case disable
}

extension ContainerViewShadowStyle {
    /// Provides the correct shadow style based on container configuration and container view configuration
    ///
    /// When the display type of container is stacking, each container view can specify its own shadow style, and the shadow style has higher priority than the shadow style of container configuration.
    /// When the container display type is  horizontal  or vertical, the shadow style of container view configuration will be ignored.
    ///
    ///     In stacking mode:
    ///
    ///     container       containerView       result
    ///
    ///     nil             nil                 disable
    ///     nil             disable             disable
    ///     disable         radius(1.3)         radius(1.3)
    ///     radius(1.0)     custom(.red,1.2,2,2) custom(.red,1.2,2,2)
    ///
    static func merge(containerShadow: Self?, viewShadow: Self?, containerViewDisplayType: ContainerViewDisplayType) -> Self {
        switch containerViewDisplayType {
        case .horizontal, .vertical:
            return containerShadow ?? .disable
        case .stacking:
            guard let containerShadow = containerShadow else { return viewShadow ?? .disable }
            return viewShadow ?? containerShadow
        }
    }
}

extension View {
    /// Add shadow to container view
    ///
    ///      var shadowStyle:ContainerViewShadowStyle {
    ///          ContainerViewShadowStyle(containerShadow: containerShadow,
    ///                                   viewShadow: viewShadow,
    ///                                   containerViewDisplayType: containerViewDisplayType)
    ///      }
    ///
    ///      containerView
    ///          .containerViewShadow(shadowStyle)
    ///
    @ViewBuilder
    func containerViewShadow(_ shadowStyle: ContainerViewShadowStyle) -> some View {
        switch shadowStyle {
        case .radius(let radius):
            self
                .compositingGroup()
                .shadow(radius: radius)
        case .custom(let color, let radius, let x, let y):
            self
                .compositingGroup()
                .shadow(color: color, radius: radius, x: x, y: y)
        case .disable:
            self
        }
    }
}
