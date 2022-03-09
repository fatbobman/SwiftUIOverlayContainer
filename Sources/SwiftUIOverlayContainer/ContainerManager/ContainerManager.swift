//
//  ContainerManager.swift
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

typealias ContainerViewPublisher = Publishers.Share<PassthroughSubject<IdentifiableContainerView, Never>>
typealias ContainerName = String

final class ContainerManager {
    var logger: SwiftUIOverlayContainerLoggerProtocol?
    var publishers: [ContainerName: ContainerViewPublisher] = [:]
}

// MARK: Container Management

extension ContainerManager: ContainerManagement {
    func registerContainer(for containerName: ContainerName) -> ContainerViewPublisher {
        checkContainer(for: containerName)
        return createPublisher(for: containerName)
    }

    func removeContainer(for containerName: ContainerName) {
        publishers.removeValue(forKey: containerName)
    }

    func getPublisher(for containerName: ContainerName) -> ContainerViewPublisher? {
        publishers[containerName]
    }

    var containerCount: Int {
        publishers.count
    }

    private func checkContainer(for containerName: ContainerName) {
        guard publishers[containerName] != nil else { return }
        removeContainer(for: containerName)
        logger?.log(type: .error, message: "Container `\(containerName)` already exists. The new container will replace the old one.")
    }

    private func createPublisher(for containerName: ContainerName) -> ContainerViewPublisher {
        let publisher = PassthroughSubject<IdentifiableContainerView, Never>().share()
        publishers[containerName] = publisher
        return publisher
    }
}
