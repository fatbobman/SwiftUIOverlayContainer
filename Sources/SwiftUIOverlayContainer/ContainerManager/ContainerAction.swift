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

/// 从 Container Manager 发送给 Contianer 的指令
enum OverlayContainerAction {
    // push view in container queue
    case show(IdentifiableContainerView)
    // dismiss the view from the container queue whether it is already displayed or not
    // Pass false to disable animation of transition
    case dismiss(UUID, Bool)
    // dismiss all views from the container queue whether thats are already displayed or not
    // Pass false to disable animation of transition
    case dismissAll(Bool)
    // dismiss all showing views from the container
    case dismissShowing(Bool)
}
