//
//  ContainerViewConfiguration.swift
//  SwiftUIOverlayContainer
//
//  Created by Yang Xu on 2022/3/9
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation
import SwiftUI

typealias DismissAction = @MainActor @Sendable () -> Void

/// A configuration protocol for container and container view
public protocol ContainerViewConfigurationProtocol {
    /// The alignment of view in container
    ///
    /// When the display type of container is stacking, each container view can specify its own alignment in container view configuration, which has higher priority than the alignment setting in container configuration.
    ///
    /// When the container display type is horizontal or vertical, the container view's alignment setting will be ignored.
    var alignment: Alignment? { get }

    /// Pass true , the view will be dismissed when the background is clicked
    ///
    /// Each view has own tapToDismiss when the container display type is stacking
    /// tapToDismiss of container view configuration will ignored when the container display type is horizontal or vertical
    var tapToDismiss: Bool? { get }

    /// The background style of the container view
    ///
    /// Each view has own background when the container display type is stacking
    ///
    /// There is only one background of container when the container display type is horizontal or vertical. the background style of container view configuration will be ignored
    var backgroundStyle: ContainerBackgroundStyle? { get }

    /// The transition of container view's background
    ///
    /// Keep the default setting ( opacity ) is a good choice
    var backgroundTransitionStyle: ContainerBackgroundTransitionStyle { get }

    /// The shadow style of container view
    ///
    /// When the display type of container is stacking, each container view can specify its own shadow style, and the shadow style has higher priority than the shadow style of container configuration.
    ///
    /// When the container display type is  horizontal  or vertical, the shadow style of container view configuration will be ignored.
    ///
    /// if your view is not fully opaque, It's better to set shadow in container view inside
    var shadowStyle: ContainerViewShadowStyle? { get }

    /// The gesture of dismiss
    ///
    /// Container view configuration's dismiss gesture has higher priority than the one of container configuration
    ///
    /// If you want to use a gesture that not be provided in default implement, you can add it in container view inside, then call dismiss action obtained from environment value ( overlayContainer ),  and set to nil in container view configuration
    var dismissGesture: ContainerViewDismissGesture? { get }

    /// Transition for showing and dismissing view
    ///
    /// Each container view can specify its own view transition, and the transition has higher priority than the one of container configuration.
    ///
    /// When the display type of container is horizontal or vertical, it is the best to use only one transition for all container views, which is set in the container configuration, and set the one in container view configuration to nil
    var transition: AnyTransition? { get }

    /// Dismiss container view automatically
    ///
    /// The autoDismiss of container view configuration has higher priority than container configuration
    ///
    /// Pass .second(2) will dismiss the view after 2 seconds automatically
    var autoDismiss: ContainerViewAutoDismiss? { get }

    /// Method called when the view is dismissed. Does not run if the view is in the temp queue ( OneByOneWaitFinish mode )
    ///
    /// Running order:
    ///
    ///     the onDisappear action in container view
    ///     the disappear action in container view configuration
    ///     the disappear action in container configuration
    ///
    var disappearAction: (() -> Void)? { get }

    /// Method called when the view is appeared. Does not run if the view is in the temp queue( OneByOneWaitFinish mod )
    ///
    /// Running order:
    ///
    ///     the onAppear action in container view
    ///     the appear action in container view configuration
    ///     the appear action in container configuration
    ///
    var appearAction: (() -> Void)? { get }

    /// The animation of transition
    ///
    /// Each container view can specify its own view animation of transition, and the animation has higher priority than the one of container configuration.
    var animation: Animation? { get }
}

public typealias ContainerView = View & ContainerViewConfigurationProtocol

public extension ContainerViewConfigurationProtocol {
    var alignment: Alignment? { nil }

    var tapToDismiss: Bool? { nil }

    var backgroundStyle: ContainerBackgroundStyle? { nil }

    var backgroundTransitionStyle: ContainerBackgroundTransitionStyle { .opacity }

    var shadowStyle: ContainerViewShadowStyle? { nil }

    var dismissGesture: ContainerViewDismissGesture? { nil }

    var transition: AnyTransition? { nil }

    var autoDismiss: ContainerViewAutoDismiss? { nil }

    var disappearAction: (() -> Void)? { nil }

    var appearAction: (() -> Void)? { nil }

    var animation: Animation? { .default }
}
