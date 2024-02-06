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

    /// Delay duration to show next view
    ///
    /// In OneByOneWaitFinish mode or In Multiple mode with limit maximum number of views at the same time,The view in temporary queue are delayed for a specific number of seconds when the currently displayed view is dismissed.
    ///
    /// Setting a reasonable delay time can give users a good feeling.
    ///
    /// Imagine if there are multiple views in the temporary queue, every time the user dismisses a current displayed view, the next view pops up immediately, which will give the user a greater sense of pressure
    var delayForShowingNext: TimeInterval { get }

    /// The maximum number of views that can show on the screen at the same time in Multiple mode
    ///
    /// Default is unlimited
    var maximumNumberOfViewsInMultipleMode: UInt { get }
}

public extension ContainerTypeConfigurationProtocol {
    var delayForShowingNext: TimeInterval { 0.5 }

    var maximumNumberOfViewsInMultipleMode: UInt { UInt.max }
}

/// A type defines partial arrangement configuration of view in the container
public protocol ContainerCompositionProtocol {
    /// Spacing between each view when the display type is horizontal or vertical, and queue type is multiple
    var spacing: CGFloat { get }
    /// Insets of view or view group in container
    ///
    /// In stacking mode, insets will be added to each view
    ///
    /// In vertical or horizontal mode, insets will be added to the view group (VStack or HStack)
    var insets: EdgeInsets { get }

    /// Clip the container to its bounding rectangle frame
    ///
    /// Pass true when the bounds of the view's transition need to limited
    /// Can't be changed dynamically
    var clipped: Bool { get }

    /// Expands the container out of its safe area.
    ///
    /// Default value is disable
    var ignoresSafeArea: ContainerIgnoresSafeArea { get }

    /// Expands the backgroud container out of its safe area.
    ///
    /// Default value is disable
    var bgIgnoresSafeArea: ContainerIgnoresSafeArea { get }
    
    /// Controls the display order of overlapping views.
    ///
    /// Default value is ascending order, new container view can overlap the old one
    var displayOrder: ContainerDisplayOrder { get }
}

public protocol ContainerQueueControlProtocol {
  var queueControlOperator: QueueControlOperator { get }
}

/// A type defines how the container handles a large number of window display requests in a short period of time
public enum QueueControlOperator:Equatable {
    /// Execute the window operation only after the specified time interval has elapsed
    /// It is only applicable to special needs scenarios, such as using OverallContainer instead of Sheet.
    /// In a List, clicking each row will pop up a window. In this case, if the user accidentally uses multiple fingers to click, it will open multiple window condition.
    /// Enable the debounce function for the container, and the container will only retain one valid operation in a short period of time. Usually just set the duetime to 0.1 seconds
    case debounce(seconds: TimeInterval)
    /// Default, execute every window operation
    case none
}

public extension ContainerCompositionProtocol {
    var spacing: CGFloat { 10 }

    var insets: EdgeInsets { .init() }

    var clipped: Bool { false }

    var ignoresSafeArea: ContainerIgnoresSafeArea { .disable }
    
    var bgIgnoresSafeArea: ContainerIgnoresSafeArea { .disable }
    
    var displayOrder: ContainerDisplayOrder { .ascending }
}

public extension ContainerQueueControlProtocol {
  var queueControlOperator:QueueControlOperator { .none }
}

/// A combined protocol that defines all the configuration of the container
public protocol ContainerConfigurationProtocol: ContainerViewConfigurationProtocol
    & ContainerTypeConfigurationProtocol
    & ContainerCompositionProtocol
    & ContainerQueueControlProtocol {}
