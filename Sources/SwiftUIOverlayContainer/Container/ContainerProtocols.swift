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

import Combine
import Foundation
import SwiftUI

public protocol ContainerTypeConfigurationProtocol {
    // viewDisplayType
    var displayType: ContainerViewDisplayType { get }

    // viewQueueType
    var queueType: ContainerViewQueueType { get }
}

public protocol ContainerCompositionProtocol {
    var spacing: CGFloat? { get }

    var insets: EdgeInsets { get }
}

extension ContainerCompositionProtocol {
    var spacing: CGFloat? { nil }

    var insets: EdgeInsets { .init() }
}

// swiftlint:disable:next line_length
public protocol ContainerConfigurationProtocol: ContainerViewConfigurationProtocol & ContainerTypeConfigurationProtocol & ContainerCompositionProtocol {}
