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

import Foundation
public protocol ContainerTypeConfigurationProtocol {
    // viewDisplayType
    var displayType: ContainerViewDisplayType { get }

    // viewQueueType
    var queueType: ContainerViewQueueType { get }
}

public protocol ContainerConfigurationProtocol: ContainerViewConfigurationProtocol & ContainerTypeConfigurationProtocol {}
