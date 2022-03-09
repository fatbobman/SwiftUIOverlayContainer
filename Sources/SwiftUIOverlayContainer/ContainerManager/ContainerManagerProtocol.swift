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

protocol ContainerManagement {
    // - MARK: 针对 Container Controller

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
    // 发送 ContainerView
}
