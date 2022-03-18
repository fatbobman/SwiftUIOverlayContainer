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

import Foundation
import SwiftUI

/// The Environment Key of container manager. An instance of container manager.
struct ContainerManagerKey: EnvironmentKey {
    static var defaultValue = ContainerManager.share
}

public extension EnvironmentValues {
    /// An environment value that wraps the instance of container manager that you can use to show a view in the specific overlay container.
    ///
    ///     struct ContentView: View {
    ///         @Environment(\.overlayContainerManager) var manager
    ///         var body: some View {
    ///             VStack{
    ///                 Button("push view by manager"){
    ///                     manager.show(view: MessageView(), in: "container2", using: MessageViewConfiguration())
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// In the most cases, you don't need use primitive methods in SwiftUI view, just use the functionality of View Extension.
    var overlayContainerManager: ContainerManager {
        get { self[ContainerManagerKey.self] }
        set { self[ContainerManagerKey.self] = newValue }
    }
}
