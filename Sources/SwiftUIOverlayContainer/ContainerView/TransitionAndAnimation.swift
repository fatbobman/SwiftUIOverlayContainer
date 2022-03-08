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

extension AnyTransition {
    /// Merge transition between container and container View
    ///
    /// When the type of Container is **Stacking**, each Container View can specify its own view transition,
    /// and the priority is higher than the transition of Container.
    /// When Container type is **Horizontal** or **Vertical**, the transition  of Container View will be ignored.
    ///
    ///     Stacking:
    ///
    ///     container               view               result
    ///        nil                  nil                identity
    ///        identity             nil                identity
    ///        move                 identity           identity
    ///
    /// Different transitions can be set for entry and exit respectively
    ///
    ///     AnyTransition.asymmetric(
    ///         insertion: .move(edge: .bottom).combined(with: .opacity),
    ///         removal: .slide.combined(with: .opacity)
    ///       )
    ///
    static func merge(
        containerTransition: AnyTransition?,
        viewTransition: AnyTransition?,
        containerViewDisplayType: ContainerViewDisplayType
    ) -> AnyTransition {
        switch containerViewDisplayType {
        case .horizontal, .vertical:
            return containerTransition ?? .identity
        case .stacking:
            guard let containerTransition = containerTransition else { return viewTransition ?? .identity }
            return viewTransition ?? containerTransition
        }
    }

    public static let hubOnTop: AnyTransition = .move(edge: .top).combined(with: .opacity)
}

extension Animation {
    /// Merge Transition Animation between container and container view
    ///
    ///       container           view          result
    ///         nil               nil           default
    ///         nil               easeIn        easeIn
    ///         default           easeIn        easeIn
    ///
    ///       var animation:Animation {
    ///           Animation.merge(
    ///                    containerAnimation: containerAnimation,
    ///                    viewAnimation: viewAnimation,
    ///                    containerViewDisplayType: containerViewDisplayType
    /// )
    ///       }
    ///
    ///       withAnimation(animation) {
    ///           // dismiss view
    ///       }
    ///
    static func merge(
        containerAnimation: Animation?,
        viewAnimation: Animation?,
        containerViewDisplayType: ContainerViewDisplayType
    ) -> Animation {
        guard let containerAnimation = containerAnimation else { return viewAnimation ?? .default }
        return viewAnimation ?? containerAnimation
    }
}
