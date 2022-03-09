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
    // when the animation is not nil, the new animation will overwrite the old setting
    case dismiss(UUID, Animation?)
    // dismiss all views from the container queue whether thats are already displayed or not
    // when the animation is not nil, the new animation will overwrite the old setting
    case dismissAll(Animation?)
}
