//
//  ModifierForContainerView.swift
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

struct ShowContainerViewModifier<V: View>: ViewModifier {
    let containerName: ContainerName
    var content: V
    let configuration: ContainerViewConfiguration
    @Binding var isPresented: Bool
    @Environment(\.containerManager) var containerManager

    init(containerName: ContainerName, content: V, configuration: ContainerViewConfiguration, isPresented: Binding<Bool>) {
        self.containerName = containerName
        self.content = content
        self.configuration = configuration
        self._isPresented = isPresented
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { _ in
                if isPresented {
                    containerManager.show(view: content, in: containerName, using: configuration, isPresented: $isPresented)
                }
            }
    }
}

public extension View {
    func containerView<Content: View>(
        in overlayContainer: String,
        configuration: ContainerViewConfiguration,
        isPresented: Binding<Bool>,
        content: () -> Content
    ) -> some View {
        self
            .modifier(
                ShowContainerViewModifier(
                    containerName: overlayContainer,
                    content: content(),
                    configuration: configuration,
                    isPresented: isPresented
                )
            )
    }
}
