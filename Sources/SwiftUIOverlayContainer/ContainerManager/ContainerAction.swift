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

/// 从 Container Manager 发送给 Contianer 的指令
enum OverlayContainerAction {
    case show(IdentifiableContainerView)
    case dismiss(UUID)
    case dismissAll
}
