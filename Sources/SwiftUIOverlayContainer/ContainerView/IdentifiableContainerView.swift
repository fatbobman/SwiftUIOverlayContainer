//
//  IdentifiableContainerView.swift
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

/// A struct that wraps container view with Identifier
public struct IdentifiableContainerView: Identifiable {
    /// The identifier for container
    public let id = UUID()

    /// View of Container View
    let view: AnyView

    /// configuration of Container View
    let configuration: ContainerViewConfiguration

    /// A switch that controls the display of the current container view
    let isPresented: Binding<Bool>?

    public init<Context: View>(view: Context, viewConfiguration: ContainerViewConfiguration, isPresented: Binding<Bool>? = nil) {
        self.view = view.eraseToAnyView()
        self.configuration = viewConfiguration
        self.isPresented = isPresented
    }
}
