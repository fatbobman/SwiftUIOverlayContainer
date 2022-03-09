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

public protocol ContainerViewConfigurationProtocol {
    // alignment
    var alignment: Alignment? { get }

    // background
    var tapToDismiss: Bool? { get }

    var backgroundStyle: ContainerBackgroundStyle? { get }

    // shadow
    var shadowStyle: ContainerViewShadowStyle? { get }

    // gesture
    var dismissGesture: ContainerViewDismissGesture? { get }

    // transition
    var transition: AnyTransition? { get }

    // autoDismiss
    var autoDismiss: ContainerViewAutoDismiss? { get }

    // action
    var disappearAction: (() -> Void)? { get }

    var appearAction: (() -> Void)? { get }

    // animation
    var animation: Animation? { get }
}

public typealias ContainerView = View & ContainerViewConfigurationProtocol

public extension ContainerViewConfigurationProtocol {
    // alignment
    var alignment: Alignment? { nil }

    // background
    var tapToDismiss: Bool? { nil }

    var backgroundStyle: ContainerBackgroundStyle? { nil }

    // shadow
    var shadowStyle: ContainerViewShadowStyle? { nil }

    // gesture
    var dismissGesture: ContainerViewDismissGesture? { nil }

    // transition
    var transition: AnyTransition? { nil }

    // autoDismiss
    var autoDismiss: ContainerViewAutoDismiss? { nil }

    // action
    var disappearAction: (() -> Void)? { {} }

    var appearAction: (() -> Void)? { {} }

    // animation
    var animation: Animation? { nil }
}
