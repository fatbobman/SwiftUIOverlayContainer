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

/// The manager of all overlay containers that provides a bridge between containers and SwiftUI views.
public final class ContainerManager {
    var publishers: [String: ContainerViewPublisher] = [:]

    private init() {}

    /// Controlled method of writing to the log
    func sendMessage(type: SwiftUIOverlayContainerLogType, message: String, debugLevel: Int = 1) {
        if debugLevel <= Self.debugLevel {
            Self.logger.log(type: type, message: message)
        }
    }
}

// MARK: - Container Management

extension ContainerManager: ContainerManagement {
    func registerContainer(for container: String) -> ContainerViewPublisher {
        checkForExist(container: container)
        return createPublisher(for: container)
    }

    func removeContainer(for container: String) {
        publishers.removeValue(forKey: container)
        sendMessage(type: .info, message: "`\(container)` has been removed from manager", debugLevel: 2)
    }

    func getPublisher(for container: String) -> ContainerViewPublisher? {
        guard let publisher = publishers[container] else {
            sendMessage(
                type: .error,
                message: "Can't get view publisher for `\(container)`,The overlay container should be registered first."
            )
            return nil
        }
        return publisher
    }

    var containerCount: Int {
        publishers.count
    }

    private func checkForExist(container: String) {
        guard publishers[container] != nil else { return }
        removeContainer(for: container)
        sendMessage(type: .error, message: "Container `\(container)` already exists. The new container will replace the old one.")
    }

    private func createPublisher(for container: String) -> ContainerViewPublisher {
        let publisher = PassthroughSubject<OverlayContainerAction, Never>().share()
        publishers[container] = publisher
        return publisher
    }
}

// MARK: - Container View Management

extension ContainerManager: ContainerViewManagementForViewModifier {
    @discardableResult
    func show<Content>(
        view: Content,
        in container: String,
        using configuration: ContainerViewConfigurationProtocol,
        isPresented: Binding<Bool>? = nil
    ) -> UUID? where Content: View {
        guard let publisher = getPublisher(for: container) else {
            return nil
        }
        let viewID = UUID()
        let identifiableContainerView = IdentifiableContainerView(
            id: viewID,
            view: view,
            viewConfiguration: configuration,
            isPresented: isPresented
        )
        publisher.upstream.send(.show(identifiableContainerView))
        sendMessage(type: .info, message: "send view `\(type(of: view))` to container: `\(container)`", debugLevel: 2)
        return viewID
    }

    @discardableResult
    func show<Content>(
        containerView: Content,
        in container: String,
        isPresented: Binding<Bool>? = nil
    ) -> UUID? where Content: ContainerView {
        show(view: containerView, in: container, using: containerView, isPresented: isPresented)
    }
}

extension ContainerManager: ContainerViewManagementForEnvironment {
    /// push ContainerView to specific overlay container
    ///
    /// Interface for environment key
    /// - Returns: container view ID
    @discardableResult
    public func show<Content>(
        view: Content,
        in container: String,
        using configuration: ContainerViewConfigurationProtocol
    ) -> UUID? where Content: View {
        show(view: view, in: container, using: configuration, isPresented: nil)
    }

    /// push ContainerView to specific overlay container
    ///
    /// Interface for environment key
    /// - Returns: container view ID
    @discardableResult
    public func show<Content>(
        containerView: Content,
        in container: String
    ) -> UUID? where Content: ContainerView {
        show(view: containerView, in: container, using: containerView, isPresented: nil)
    }

    public func dismiss(view id: UUID, in container: String, animated flag: Bool) {
        guard let publisher = getPublisher(for: container) else {
            return
        }
        publisher.upstream.send(.dismiss(id, flag))
    }

    public func dismissAllView(notInclude excludeContainers: [String], onlyShowing: Bool = false, animated flag: Bool) {
        let publishers = publishers.filter { !excludeContainers.contains($0.key) }.values
        for publisher in publishers {
            if onlyShowing {
                publisher.upstream.send(.dismissShowing(flag))
            } else {
                publisher.upstream.send(.dismissAll(flag))
            }
        }
    }

    public func dismissAllView(in containers: [String], onlyShowing: Bool = false, animated flag: Bool) {
        for container in containers {
            if let publisher = getPublisher(for: container) {
                if onlyShowing {
                    publisher.upstream.send(.dismissShowing(flag))
                } else {
                    publisher.upstream.send(.dismissAll(flag))
                }
            }
        }
    }
}

// MARK: - Logger

extension ContainerManager: ContainerManagerLogger {
    public static var logger: SwiftUIOverlayContainerLoggerProtocol = SwiftUIOverlayContainerDefaultLogger()
    /// Debug Level for log output. 0 disable 1 basic 2 more detail
    public static var debugLevel = 0
}

// MARK: - shared

public extension ContainerManager {
    static let shared = ContainerManager()
}
