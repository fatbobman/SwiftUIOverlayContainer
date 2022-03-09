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
import SwiftUI

typealias ContainerViewPublisher = Publishers.Share<PassthroughSubject<IdentifiableContainerView, Never>>
typealias ContainerName = String

public final class ContainerManager {
    var publishers: [ContainerName: ContainerViewPublisher] = [:]

    private init() {}
}

// MARK: - Container Management

extension ContainerManager: ContainerManagement {
    func registerContainer(for containerName: ContainerName) -> ContainerViewPublisher {
        checkForExist(containerName: containerName)
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

    private func checkForExist(containerName: ContainerName) {
        guard publishers[containerName] != nil else { return }
        removeContainer(for: containerName)
        sendMessage(type: .error, message: "Container `\(containerName)` already exists. The new container will replace the old one.")
    }

    private func createPublisher(for containerName: ContainerName) -> ContainerViewPublisher {
        let publisher = PassthroughSubject<IdentifiableContainerView, Never>().share()
        publishers[containerName] = publisher
        return publisher
    }
}

// MARK: - Container View Management

extension ContainerManager: ContainerViewManagement {
    func show<Content>(
        view: Content,
        in containerName: ContainerName,
        using configuration: ContainerViewConfiguration,
        isPresented: Binding<Bool>? = nil
    ) where Content: View {
        guard let publisher = getPublisher(for: containerName) else {
            sendMessage(type: .error, message: "Can't get view publisher for `\(containerName)`")
            return
        }
        let identifiableContainerView = IdentifiableContainerView(view: view, viewConfiguration: configuration, isPresented: isPresented)
        publisher.upstream.send(identifiableContainerView)
    }
}

// MARK: - Logger

extension ContainerManager: ContainerManagerLogger {
    public static var logger: SwiftUIOverlayContainerLoggerProtocol = SwiftUIOverlayContainerDefaultLogger()
    public static var enableLog = true

    /// Controlled method of writing to the log
    func sendMessage(type: SwiftUIOverlayContainerLogType, message: String) {
        if Self.enableLog {
            Self.logger.log(type: type, message: message)
        }
    }
}

// MARK: - shared

public extension ContainerManager {
    static let shared = ContainerManager()
}
