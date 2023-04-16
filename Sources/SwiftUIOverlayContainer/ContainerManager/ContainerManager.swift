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
///
/// In the SwiftUI view, it is better to call the Container Manager by accessing the environment value
///
///     struct ContentView: View {
///         @Environment(\.overlayContainerManager) var manager
///         var body: some View {
///             VStack{
///                 Button("push view by manager"){
///                     manager.show(view: Text("ab"), in: "container2", using: MessageView())
///                 }
///             }
///         }
///     }
///
/// Because the Container Manager adopts the singleton pattern, you can directly call public methods such as show and dismiss through code even if you are not in the SwiftUI view.
public final class ContainerManager: ContainerManagerLogger {
    var publishers: [String: ContainerViewPublisher] = [:]

    public init(logger: SwiftUIOverlayContainerLoggerProtocol? = nil, debugLevel: Int = 0) {
        if logger == nil {
            self.logger = SwiftUIOverlayContainerDefaultLogger()
        }
        self.debugLevel = debugLevel
    }

    public var logger: SwiftUIOverlayContainerLoggerProtocol?
    /// Debug Level for log output. 0 disable 1 basic 2 more detail
    public var debugLevel: Int

    /// Controlled method of writing to the log
    func sendMessage(type: SwiftUIOverlayContainerLogType, message: String, debugLevel: Int = 1) {
        if debugLevel <= self.debugLevel {
            self.logger?.log(type: type, message: message)
        }
    }
}

// MARK: - Container Management

extension ContainerManager: ContainerManagement {
    /// Register a container in the container manager
    ///
    /// Overlay containers will register themselves when they appear ( onAppear ), called by container
    func registerContainer(for container: String) -> ContainerViewPublisher {
        checkForExist(container: container)
        return createPublisher(for: container)
    }

    /// Remove a container from the container manager, called by container
    ///
    /// Overlay containers will remove themselves from manager when the disappear ( onDisappear ).
    func removeContainer(for container: String) {
        publishers.removeValue(forKey: container)
        sendMessage(type: .info, message: "`\(container)` has been removed from manager", debugLevel: 2)
    }

    /// Get  publisher of container action  for specific container from manager, called by container
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

    /// The count of registered containers
    var containerCount: Int {
        publishers.count
    }

    /// Check if the container has registered
    private func checkForExist(container: String) {
        guard publishers[container] != nil else { return }
        removeContainer(for: container)
        sendMessage(type: .error, message: "Container `\(container)` already exists. The new container will replace the old one.")
    }

    /// Create a publisher of action for specific container.
    private func createPublisher(for container: String) -> ContainerViewPublisher {
        // Convert to reference type to support dumping
        let publisher = PassthroughSubject<OverlayContainerAction, Never>().share()
        publishers[container] = publisher
        return publisher
    }
}

// MARK: - Container View Management

extension ContainerManager: ContainerViewManagementForViewModifier {
    /// Show a view in specific container.
    /// - Returns: the ID of view. you can use this ID to dismiss the view by code
    @discardableResult
    func _show<Content>(
        view: Content,
        with ID: UUID? = nil,
        in container: String,
        using configuration: ContainerViewConfigurationProtocol,
        isPresented: Binding<Bool>? = nil,
        animated: Bool = true
    ) -> UUID? where Content: View {
        guard let publisher = getPublisher(for: container) else {
            return nil
        }
        let viewID = ID ?? UUID() // If no specific ID is given, generate a new ID
        let identifiableContainerView = IdentifiableContainerView(
            id: viewID,
            view: view,
            viewConfiguration: configuration,
            isPresented: isPresented
        )
        publisher.upstream.send(.show(identifiableContainerView, animated))
        sendMessage(type: .info, message: "send view `\(type(of: view))` to container: `\(container)`", debugLevel: 2)
        return viewID
    }

    @discardableResult
    func _show<Content>(
        containerView: Content,
        in container: String,
        isPresented: Binding<Bool>? = nil
    ) -> UUID? where Content: ContainerView {
        _show(view: containerView, in: container, using: containerView, isPresented: isPresented)
    }
}

extension ContainerManager: ContainerViewManagementForEnvironment {
    /// Push ContainerView to specific overlay container
    ///
    /// Interface for environment key
    /// - Returns: container view ID
    @discardableResult
    public func show<Content>(
        view: Content,
        with ID: UUID? = nil,
        in container: String,
        using configuration: ContainerViewConfigurationProtocol,
        animated: Bool = true
    ) -> UUID? where Content: View {
        _show(view: view, with: ID, in: container, using: configuration, isPresented: nil, animated: animated)
    }

    /// Push ContainerView to specific overlay container
    ///
    /// Interface for environment key
    /// - Returns: container view ID
    @discardableResult
    public func show<Content>(
        containerView: Content,
        with ID: UUID? = nil,
        in container: String,
        animated: Bool = true
    ) -> UUID? where Content: ContainerView {
        _show(view: containerView, with: ID, in: container, using: containerView, isPresented: nil, animated: animated)
    }

    /// Dismiss a specific view in a specific container
    /// - Parameters:
    ///   - id: ID of the view ( IdentifiableView , the result of show method)
    ///   - container: The container to which the view has been pushed
    ///   - flag: Pass false, no animation when dismiss the view
    public func dismiss(view id: UUID, in container: String, animated flag: Bool) {
        guard let publisher = getPublisher(for: container) else {
            return
        }
        publisher.upstream.send(.dismiss(id, flag))
    }

    /// Dismiss all views of all containers that has registered exclude  containers in the excludeContainers list.
    /// - Parameters:
    ///   - excludeContainers: Containers in excludeContainers list will not get dismiss action.
    ///   - onlyShowing: Only dismiss the view that is be displaying (in mainQueue). Applies only to oneByOneWaitFinish mode. after dismiss, the view in the tempQueue will be displayed.
    ///   - flag: Pass false, no animation when dismiss the view
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

    /// Dismiss all view of the containers in containers list.
    /// - Parameters:
    ///   - containers: Dismissed only the views of the containers in the list.
    ///   - onlyShowing: Only dismiss the view that is be displaying (in mainQueue). Applies only to oneByOneWaitFinish mode. after dismiss, the view in the tempQueue will be displayed.
    ///   - flag: Pass false, no animation when dismiss the view
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

    /// Dismiss the top view in the containers
    /// - Parameters:
    ///   - containers: container names
    ///   - flag: Pass false, disable animation when dismiss the view
    public func dismissTopmostView(in containers: [String], animated flag: Bool) {
        for container in containers {
            if let publisher = getPublisher(for: container) {
                publisher.upstream.send(.dismissTopmostView(flag))
            }
        }
    }
}

public extension ContainerManager {
    static let share = ContainerManager()
}
