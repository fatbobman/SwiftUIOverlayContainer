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

import Combine
import Foundation
import SwiftUI

typealias ContainerViewPublisher = Publishers.Share<PassthroughSubject<OverlayContainerAction, Never>>

/// A type defines how the container manager interactive with the container
protocol ContainerManagement {
    /// Register a container in the container manager
    func registerContainer(for container: String) -> ContainerViewPublisher

    /// Remove a container from the container manager
    func removeContainer(for container: String)

    /// The count of containers
    var containerCount: Int { get }

    /// Get  container view publisher for specific container
    func getPublisher(for container: String) -> ContainerViewPublisher?
}

/// A type defines how the container manager interactive with SwiftUI view modifier
protocol ContainerViewManagementForViewModifier {
    /// Show container view in specific container
    /// - Returns: container view ID
    @discardableResult
    func _show<Content: View>(view: Content,
                              in container: String,
                              using configuration: ContainerViewConfigurationProtocol,
                              isPresented: Binding<Bool>?,
                              animated: Bool) -> UUID?

    /// Show container view in specific container
    /// - Returns: container view ID
    @discardableResult
    func _show<Content: ContainerView>(containerView: Content,
                                       in container: String,
                                       isPresented: Binding<Bool>?) -> UUID?
}

/// A type defines some methods for communicating between the container manager and SwiftUI views or cods outside the views.
public protocol ContainerViewManagementForEnvironment {
    /// push ContainerView to specific overlay container
    ///
    /// Interface for environment key
    /// - Returns: container view ID
    func show<Content>(
        view: Content,
        in container: String,
        using configuration: ContainerViewConfigurationProtocol,
        animated: Bool
    ) -> UUID? where Content: View

    /// push ContainerView to specific overlay container
    ///
    /// Interface for environment key
    /// - Returns: container view ID
    func show<Content>(
        containerView: Content,
        in container: String,
        animated: Bool
    ) -> UUID? where Content: ContainerView

    /// Dismiss view of specific container
    ///
    /// - Parameters:
    ///   - id: container view ID
    ///   - container: overlay container name
    ///   - flag: pass true to animate the transition
    func dismiss(view id: UUID, in container: String, animated flag: Bool)

    /// Dismiss all views of containers, excluding specific containers
    ///
    /// - Parameters:
    ///   - excludeContainers: excluded container name
    ///   - flag: pass true to animate the transition
    func dismissAllView(notInclude excludeContainers: [String], onlyShowing: Bool, animated flag: Bool)

    /// Dismiss all views of specific containers
    ///
    /// - Parameters:
    ///   - containers: container names
    ///   - flag: pass true to animate the transition
    func dismissAllView(in containers: [String], onlyShowing: Bool, animated flag: Bool)
}

/// A type defines logging behavior
protocol ContainerManagerLogger {
    /// A Instance of SwiftUIOverlayContainerLoggerProtocol for write log
    var logger: SwiftUIOverlayContainerLoggerProtocol? { get set }

    /// Level for log output, set to zero means disable log output
    var debugLevel: Int { get set }

    /// Controlled method of writing to the log
    func sendMessage(type: SwiftUIOverlayContainerLogType, message: String, debugLevel: Int)
}
