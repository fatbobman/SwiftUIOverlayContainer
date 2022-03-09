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
    /// A environment value for container manager, you can send a view to specific overlay container through it.
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
