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
/// Horizontal: the views are arranged horizontally. Normally (spacing is greater than 0), views do not overlap each other. Internal implementation uses HStack.
///
///  Vertical: the views are arranged vertically, under normal conditions (spacing greater than 0), there is no overlap between views. Usually used to implement information tips at the top or bottom of the screen. The internal implementation uses VStack.
///
/// Stacking: Aligns the views along the Z-axis. Views will overlay each other. ZStack is used for internal implementation. When ContainerViewQueueType is oneByeOne or oneBy
///
/// Works with ContainerViewQueueType to create different effects.
///
public enum ContainerViewDisplayType {
    case horizontal
    case vertical
    case stacking
}

/// 容器的显示队列类型。此类型将决定是否允许在容器中同时存在多个视图
///
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
