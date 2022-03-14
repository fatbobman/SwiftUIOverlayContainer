//
//  ContainerProtocols.swift
//  SwiftUIOverlayContainer
//
//  Created by Yang Xu on 2022/3/9
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Combine
import Foundation
import SwiftUI

/// A type defines the display type and queue handling type for container
public protocol ContainerTypeConfigurationProtocol {
    /// The display type of view in container
    ///
    /// This parameter will determine how the views will be arranged in the container
    var displayType: ContainerViewDisplayType { get }

    /// The queue handling type of container
    ///
    /// Different queue handling type will determine whether to run logic such as displaying multiple view at the same time, if the new view will automatically replace the old one. etc.
    var queueType: ContainerViewQueueType { get }

    /// In OneByOneWaitFinish mode,The view in temporary queue are delayed for a specific number of seconds when the currently displayed view is dismissed.
    ///
    /// Setting a reasonable delay time can give users a good feeling.
    ///
    /// Imagine if there are multiple views in the temporary queue, every time the user dismisses a current displayed view, the next view pops up immediately, which will give the user a greater sense of pressure
    var delayForShowingNext: TimeInterval { get }
}

public extension ContainerTypeConfigurationProtocol {
    var delayForShowingNext: TimeInterval { 0.5 }
}

/// A type defines partial arrangement configuration of view in the container
public protocol ContainerCompositionProtocol {
    /// Spacing between each view when the display type is horizontal or vertical, and queue type is mulitple
    var spacing: CGFloat? { get }
    /// Insets of view or view group in container
    ///
    /// In stacking mode, insets will be added to each view
    ///
    /// In vertical or horizontal mode, insets will be added to the view group (VStack or HStack)
    var insets: EdgeInsets { get }
}

public extension ContainerCompositionProtocol {
    var spacing: CGFloat? { nil }

    var insets: EdgeInsets { .init() }
}

/// A combined protocol that defines all the configuration of the container
public protocol ContainerConfigurationProtocol: ContainerViewConfigurationProtocol
    & ContainerTypeConfigurationProtocol
    & ContainerCompositionProtocol {}
