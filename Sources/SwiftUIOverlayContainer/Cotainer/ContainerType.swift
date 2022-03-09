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

/// The display type of the container view, this type will determine the layout used for the container
///
/// **horizontal**: the views are arranged horizontally. Normally (spacing is greater than 0), views do not overlap each other. Internal implementation uses HStack.
///
/// **vertical**: the views are arranged vertically, under normal conditions (spacing greater than 0), there is no overlap between views. Usually used to implement information tips at the top or bottom of the screen. The internal implementation uses VStack.
///
/// **stacking**: Aligns the views along the Z-axis. Views will overlay each other. ZStack is used for internal implementation. When ContainerViewQueueType is oneByeOne or oneBy
///
public enum ContainerViewDisplayType {
    case horizontal
    case vertical
    case stacking
}

/// The display queue type of the container. This type will determine if multiple views are allowed to exist in the container at the same time
///
/// **oneByOne**: Only one view can be displayed at a time. When the container receives a new view, the current view will be canceled and the new view will be displayed.
///
/// **oneByOneWaitFinish**: Only one view can be displayed at a time. The new view needs to wait for the current view to be closed (user manual, Binding value, auto dismiss) before it can be displayed.
///
/// **multiple**: Multiple views can be displayed at once. The display result depends on the containerViewDisplayType.
///
public enum ContainerViewQueueType {
    case oneByOne
    case oneByOneWaitFinish
    case multiple
}

public enum ContainerSize {
    case scene
    case view
}
