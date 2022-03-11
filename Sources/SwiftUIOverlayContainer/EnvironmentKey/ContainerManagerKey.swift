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

struct ContainerManagerKey: EnvironmentKey {
    static var defaultValue = ContainerManager.shared
}

public extension EnvironmentValues {
    /// An environment value that wraps the instance of container manager that you can use to show a view in the specific overlay container.
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
    var overlayContainerManager: ContainerManager { self[ContainerManagerKey.self] }
}
