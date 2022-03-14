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
    /// Provides the correct transition mode of view based on the container configuration and container view configuration
    ///
    /// Each container view can specify its own view transition, and the transition has higher priority than the one of container configuration.
    ///
    /// When the display type of container is horizontal or vertical, it is the best to use only one transition for all container views, which is set in the container configuration, and set the one in container view configuration to nil
    ///
    ///     container               view               result
    ///
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
        return viewTransition ?? containerTransition ?? .identity
    }

    /// An example showing how to customize a transition for specific case.
    public static let popMessageFromTop: AnyTransition = .move(edge: .top).combined(with: .opacity)
}

extension Animation {
    /// Provides the correct animation of transition based on the container configuration and the container view configuration
    ///
    /// Each container view can specify its own view animation of transition, and the animation has higher priority than the one of container configuration.
    ///
    ///       container           view          result
    ///         nil               nil           disable
    ///         nil               easeIn        easeIn
    ///         default           easeIn        easeIn
    ///
    ///       var animation:Animation? {
    ///           Animation.merge(
    ///                    containerAnimation: containerAnimation,
    ///                    viewAnimation: viewAnimation,
    ///                    containerViewDisplayType: containerViewDisplayType
    ///             )
    ///       }
    ///
    ///       withAnimation(animation)  {
    ///           // dismiss view
    ///       }
    ///
    static func merge(
        containerAnimation: Animation?,
        viewAnimation: Animation?
    ) -> Animation {
        return viewAnimation ?? containerAnimation ?? Animation.disable
    }

    static var disable: Animation {
        .easeIn(duration: 0)
    }
}
