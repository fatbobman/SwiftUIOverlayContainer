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

protocol ContainerViewManagement {
    /// Show container view in specific container
    func show<Content: View>(view: Content,
                             in containerName: ContainerName,
                             using configuration: ContainerViewConfiguration,
                             isPresented: Binding<Bool>?)
}

protocol ContainerManagerLogger {
    /// Weather allow to log output
    static var enableLog: Bool { get set }

    /// A Instance of SwiftUIOverlayContainerLoggerProtocol for write log
    static var logger: SwiftUIOverlayContainerLoggerProtocol { get set }
}
