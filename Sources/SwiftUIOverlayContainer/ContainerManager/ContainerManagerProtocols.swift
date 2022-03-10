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

protocol ContainerManagement {
    /// Register a container in the container manager
    func registerContainer(for containerName: ContainerName) -> ContainerViewPublisher

    /// Remove a container from the container manager
    func removeContainer(for containerName: ContainerName)

    /// The count of containers
    var containerCount: Int { get }

    /// Get  container view publisher for specific container
    func getPublisher(for containerName: ContainerName) -> ContainerViewPublisher?
}

/// The methods provider to ViewModifier
protocol ContainerViewManagementForViewModifier {
    /// Show container view in specific container
    /// - Returns: container view ID
    @discardableResult
    func show<Content: View>(view: Content,
                             in containerName: ContainerName,
                             using configuration: ContainerViewConfigurationProtocol,
                             isPresented: Binding<Bool>?) -> UUID?

    /// Show container view in specific container
    /// - Returns: container view ID
    @discardableResult
    func show<Content: ContainerView>(containerView: Content,
                                      in containerName: ContainerName,
                                      isPresented: Binding<Bool>?) -> UUID?
}

/// The methods provider to Environment, can also be called by directly passing the share instance
public protocol ContainerViewManagementForEnvironment {
    /// push ContainerView to specific overlay container
    ///
    /// Interface for environment key
    /// - Returns: container view ID
    func show<Content>(
        view: Content,
        in containerName: String,
        using configuration: ContainerViewConfigurationProtocol
    ) -> UUID? where Content: View

    /// push ContainerView to specific overlay container
    ///
    /// Interface for environment key
    /// - Returns: container view ID
    func show<Content>(
        containerView: Content,
        in containerName: String
    ) -> UUID? where Content: ContainerView

    /// Dismiss view of specific container
    ///
    /// If animation is not nil, the new animation will overwrite the old setting
    func dismiss(view id: UUID, in container: String, with animation: Animation?)

    /// Dismiss all views of containers, excluding specific containers
    ///
    /// If animation is not nil, the new animation will overwrite the old setting
    func dismissAllView(notInclude excludeContainers: [String], with animation: Animation?)

    /// Dismiss all views of specific containers
    ///
    /// If animation is not nil, the new animation will overwrite the old setting
    func dismissAllView(in containers: [String], with animation: Animation?)
}

protocol ContainerManagerLogger {
    /// Weather allow to log output
    static var enableLog: Bool { get set }

    /// A Instance of SwiftUIOverlayContainerLoggerProtocol for write log
    static var logger: SwiftUIOverlayContainerLoggerProtocol { get set }

    /// Level for log output
    static var debugLevel: Int { get set }
}
