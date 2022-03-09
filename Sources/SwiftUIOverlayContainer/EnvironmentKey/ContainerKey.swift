//
//  ContainerKey.swift
//  SwiftUIOverlayContainer
//
//  Created by Yang Xu on 2022/3/9
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation
import SwiftUI

public struct ContainerEnvironment {
    public init(
        containerName: String,
        containerSize: CGSize,
        containerViewDisplayType: ContainerViewDisplayType,
        containerViewQueueType: ContainerViewQueueType,
        dismiss: @escaping () -> Void
    ) {
        self.containerName = containerName
        self.containerSize = containerSize
        self.containerViewDisplayType = containerViewDisplayType
        self.containerViewQueueType = containerViewQueueType
        self.dismiss = dismiss
    }

    let containerName: String
    let containerSize: CGSize
    let containerViewDisplayType: ContainerViewDisplayType
    let containerViewQueueType: ContainerViewQueueType
    var dismiss: () -> Void
}

public struct ContainerEnvironmentKey: EnvironmentKey {
    public static var defaultValue = ContainerEnvironment(
        containerName: "Can only be used in container views",
        containerSize: .zero,
        containerViewDisplayType: .stacking,
        containerViewQueueType: .multiple,
        dismiss: {}
    )
}

public extension EnvironmentValues {
    var overlayContainer: ContainerEnvironment { self[ContainerEnvironmentKey.self] }
}
