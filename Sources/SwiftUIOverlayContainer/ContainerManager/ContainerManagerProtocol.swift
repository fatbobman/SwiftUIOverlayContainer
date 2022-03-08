//
//  File.swift
//
//
//  Created by Yang Xu on 2022/3/7
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation

protocol OverlayContainerManagerProtocol {
    /// 注册 Container
    func registerContainer(name: String)

    /// 撤销 Container
    func removeContainer(name: String)

    /// 在 Container 中显示View,by protocol，另外还应该包含与视图绑定的Binding值（通过值控制视图的退出）
//    func show(view: OverlayContainerViewProtocol, in container: String)

    /// 在 Container 中显示 View， 通过 configuration
}
