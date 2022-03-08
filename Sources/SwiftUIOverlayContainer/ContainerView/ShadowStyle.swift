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

/// The shadow style of Container View
///
///
/// custom shadow's parameters:
///
///     .custom(color:Color, radius:CGFloat, x:CGFloat, y:CGFloat)
///
public enum ContainerViewShadowStyle {
    case radius(CGFloat)
    case custom(Color, CGFloat, CGFloat, CGFloat)
    case none
}

extension ContainerViewShadowStyle {
    /// merge shadow style between container and container View
    ///
    /// When the type of Container is **Stacking**, each Container View can specify its own shadow style,
    /// and the priority is higher than the shadow style of Container.
    /// When Container type is  **Horizontal**  or **Vertical**, the shadow style of Container View will be ignored.
    ///
    ///     container       containerView       result
    ///     nil             nil                 none
    ///     nil             none                none
    ///     none            radius(1.3)         radius(1.3)
    ///     radius(1.0)     custom(.red,1.2,2,2) custom(.red,1.2,2,2)
    ///
    static func merge(containerShadow: Self?, viewShadow: Self?, containerViewDisplayType: ContainerViewDisplayType) -> Self {
        switch containerViewDisplayType {
        case .horizontal, .vertical:
            return containerShadow ?? .none
        case .stacking:
            guard let containerShadow = containerShadow else { return viewShadow ?? .none }
            return viewShadow ?? containerShadow
        }
    }
}

extension View {
    /// add shadow to container view
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
        case .none:
            self
        }
    }
}
