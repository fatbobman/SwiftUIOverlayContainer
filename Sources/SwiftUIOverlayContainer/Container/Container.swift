//
//  Contianer.swift
//
//
//  Created by Yang Xu on 2022/3/5
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation
import SwiftUI

public extension View {
    func overlayContainer(_ containerName: String, containerConfiguration: ContainerConfigurationProtocol) -> some View {
        self
    }
}

struct SwiftUIOverlayContainerModifier: ViewModifier {
    @Environment(\.overlayContainerManager) var manager
    let configuration: ContainerConfigurationProtocol
    let containerName: String
    init(containerName: String, configuration: ContainerConfigurationProtocol) {
        self.containerName = containerName
        self.configuration = configuration
    }

    func body(content: Content) -> some View {
        content
            .overlay(SwiftUIOverlayContainer(containerName: containerName, configuration: configuration, containerManager: manager))
    }
}

struct SwiftUIOverlayContainer: View {
    let configuration: ContainerConfigurationProtocol
    let containerName: String
    @StateObject var queueHandler: ContainerQueueHandler

    init(containerName: String, configuration: ContainerConfigurationProtocol, containerManager: ContainerManager) {
        self.containerName = containerName
        self.configuration = configuration
        let handler = ContainerQueueHandler(
            container: containerName,
            containerConfiguration: configuration,
            containerManager: containerManager
        )
        _queueHandler = StateObject(wrappedValue: handler)
    }

    var body: some View {
        Text("")
    }
}
