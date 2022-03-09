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
struct IdentifiableContainerView: Identifiable {
    let id = UUID()
    let view: AnyView
    let viewConfiguration: ContainerViewConfiguration

    init<Context: View>(view: Context, viewConfiguration: ContainerViewConfiguration) {
        self.view = view.eraseToAnyView()
        self.viewConfiguration = viewConfiguration
    }
}
