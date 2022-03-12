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

    // Pass true will empty all queue when container is disappeared
    var emptyQueueAfterDisappear: Bool { get }
}

public extension ContainerTypeConfigurationProtocol {
    var emptyQueueAfterDisappear: Bool { true }
}

public protocol ContainerCompositionProtocol {
    var spacing: CGFloat? { get }

    var insets: EdgeInsets { get }
}

public extension ContainerCompositionProtocol {
    var spacing: CGFloat? { nil }

    var insets: EdgeInsets { .init() }
}

// swiftlint:disable:next line_length
public protocol ContainerConfigurationProtocol: ContainerViewConfigurationProtocol & ContainerTypeConfigurationProtocol & ContainerCompositionProtocol {}
