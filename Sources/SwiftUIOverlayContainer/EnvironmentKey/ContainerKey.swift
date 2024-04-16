//
//  ContainerKey.swift
//  SwiftUIOverlayContainer
//
//  Created by Yang Xu on 2022/3/9
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation
import SwiftUI

/// The Environment Key of overlay container
public struct ContainerEnvironment: @unchecked Sendable {
    public init(
        containerName: String,
        containerFrame: CGRect,
        containerViewDisplayType: ContainerViewDisplayType,
        containerViewQueueType: ContainerViewQueueType,
        dismiss: @escaping () -> Void
    ) {
        self.containerName = containerName
        self.containerFrame = containerFrame
        self.containerViewDisplayType = containerViewDisplayType
        self.containerViewQueueType = containerViewQueueType
        self.dismiss = dismiss
    }

    /// The name of container
    public let containerName: String
    /// The frame information of the container in global coordinateSpace
    public let containerFrame: CGRect
    /// Display type of container
    public let containerViewDisplayType: ContainerViewDisplayType
    /// Queue type of container
    public let containerViewQueueType: ContainerViewQueueType
    /// The method that can dismiss the current overlay view when call it
    ///
    /// You should call it in your SwiftUI view.
    ///
    ///     struct MessageView1: View {
    ///         @Environment(\.overlayContainer) var container
    ///         var body: some View {
    ///             RoundedRectangle(cornerRadius: 10)
    ///                 .fill(Color.orange)
    ///                 .padding(.horizontal, 20)
    ///                 .frame(height: 50)
    ///                 .overlay(Text("Hello world")
    ///                 .onTapGesture {
    ///                         container.dismiss()  // dismiss the view itself
    ///                 })
    ///         }
    ///     }
    ///
    /// The dismiss method not only includes the close action, but also executes the disappearAction closure in  containerViewConfiguration and containerConfiguration
    public var dismiss: () -> Void
}

/// An Environment Key that provides some informations and methods about container in the container views.
public struct ContainerEnvironmentKey: EnvironmentKey {
    public static let defaultValue = ContainerEnvironment(
        containerName: "`ContainerEnvironmentKey` Can only be used in container views",
        containerFrame: .zero,
        containerViewDisplayType: .stacking,
        containerViewQueueType: .multiple,
        dismiss: {
            print("[WARNING] : `ContainerEnvironmentKey` Can only be used in container views")
        }
    )
}

public extension EnvironmentValues {
    /// An Environment Value that provides some informations and methods about the container in the container views.
    var overlayContainer: ContainerEnvironment {
        get { self[ContainerEnvironmentKey.self] }
        set { self[ContainerEnvironmentKey.self] = newValue }
    }
}
