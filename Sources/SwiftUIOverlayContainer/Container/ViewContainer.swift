//
//  OverlayContainer.swift
//  SwiftUIOverlayContainer
//
//  Created by Yang Xu on 2022/3/18
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation
import SwiftUI

/// A empty Container view.
///
/// Used when you want to use overlayContainer directly instead of attaching it to a view.
///
///     // use
///     
///         ViewContainer("viewDemo",configuration: .viewConfigurationDemo)
///             .frame(minHeight:300)
///
///     // replace
///
///        ZStack {
///             Color.clear
///        }
///        .frame(minHeight: 300)
///        .overlayContainer("viewDemo", containerConfiguration: .viewConfigurationDemo)
///
public struct ViewContainer: View {
    let name: String
    let configuration: ContainerConfigurationProtocol

    public init(_ name: String, configuration: ContainerConfigurationProtocol) {
        self.name = name
        self.configuration = configuration
    }

    public var body: some View {
        Color.clear
            .overlayContainer(name, containerConfiguration: configuration)
    }
}
