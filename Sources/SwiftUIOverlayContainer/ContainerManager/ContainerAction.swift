//
//  ContainerAction.swift
//  SwiftUIOverlayContainer
//
//  Created by Yang Xu on 2022/3/10
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation
import SwiftUI

/// Actions sent from the container manager to a container
enum OverlayContainerAction {
    /// Push view in container queue, the container will push the view to the correct queue bases on its queue type.
    ///
    /// Pass false to disable animation regardless of the animation setting in container configuration or container view configuration
    case show(IdentifiableContainerView, Bool)
    /// Dismiss the view from the container queue whether or not it is already displayed.
    ///
    /// Pass false to disable animation of transition
    case dismiss(UUID, Bool)
    /// Dismiss all views in the container views queue whether or not thats are already displayed
    ///
    /// Pass false to disable animation of transition
    case dismissAll(Bool)
    /// Dismiss the view being displayed in the container, after which the first view in the temp queue is displayed (OneByOneWaitFinish mode).
    ///
    /// Pass false to disable animation of transition
    case dismissShowing(Bool)
    /// Dismiss the top view in the container
    ///
    /// Pass false to disable animation of transition
    case dismissTopmostView(Bool)
    /// Get specific container's view queue
    ///
    /// Pass container's name and a IdentifiableContainerViewQuery instance
    case viewQuery(String, IdentifiableContainerViewQuery)
}
