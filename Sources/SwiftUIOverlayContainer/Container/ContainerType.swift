//
//  ContainerSettings.swift
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

/// The display type of the container view, this type will determine the layout of the container
public enum ContainerViewDisplayType {
    /// The views are arranged horizontally. Normally (spacing is greater than 0), views do not overlap each other. Internal implementation uses HStack.
    ///
    /// In horizontal mode, all views share a single background
    case horizontal
    /// The views are arranged vertically, under normal conditions (spacing greater than 0), there is no overlap between views. Usually used to implement information tips at the top or bottom of the screen. The internal implementation uses VStack.
    ///
    /// In vertical mode, all views share a single background
    case vertical
    /// Aligns the views along the Z-axis. Views will be stacked on the top of each other. ZStack is used for internal implementation.
    ///
    /// In stacking mode, each view has own background
    case stacking
}

/// The  view queue type of the container. This type will determine if multiple views are allowed to exist in the container at the same time
public enum ContainerViewQueueType {
    ///  Only one view can be displayed at a time. When the container receives a new view, the current view will be dismissed and the new view will be displayed.
    case oneByOne
    /// Only one view can be displayed at a time. A new view needs to wait until the current view is dismissed (close call dismiss code, Binding value, auto dismiss, etc.) before it can be displayed.
    case oneByOneWaitFinish
    /// Multiple views can be displayed at once. The arrangement of the views depends on the view display type of container
    ///
    /// The maximum number of view that can show at the same time base one maximumNumberOfViewsInMultipleMode
    case multiple
}
