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

/// 容器视图的显示类型，此类型将决定容器采用的布局方式
///
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
