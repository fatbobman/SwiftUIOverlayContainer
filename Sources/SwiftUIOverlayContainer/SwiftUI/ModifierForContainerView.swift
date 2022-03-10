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
    let container: String
    var content: V
    let configuration: ContainerViewConfigurationProtocol
    @Binding var isPresented: Bool
    @Environment(\.overlayContainerManager) var containerManager

    init(container: String, content: V, configuration: ContainerViewConfigurationProtocol, isPresented: Binding<Bool>) {
        self.container = container
        self.content = content
        self.configuration = configuration
        self._isPresented = isPresented
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { _ in
                if isPresented {
                    containerManager.show(view: content, in: container, using: configuration, isPresented: $isPresented)
                }
            }
    }
}

public extension View {
    /// Sends a view to specific overlay container when the binding to the boolean you provide is true.
    ///
    ///     struct ContentView: View {
    ///         @State var show = false
    ///         var body: some View {
    ///             VStack{
    ///                 Button("push view by isPresented"){
    ///                     show.toggle()
    ///                 }
    ///         }
    ///         .containerView(in: "container1", configuration: CustomViewConfig(), isPresented: $show){
    ///              RoundedRectangle(cornerRadius: 10)
    ///                 .fill(.regularMaterial)
    ///                 .frame(height:100)
    ///                 .overlay(Text("Overlay Message"))
    ///                 .padding()
    ///             }
    ///         }
    ///     }
    ///
    func containerView<Content: View>(
        in overlayContainer: String,
        configuration: ContainerViewConfigurationProtocol,
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        self
            .modifier(
                ShowContainerViewModifier(
                    container: overlayContainer,
                    content: content(),
                    configuration: configuration,
                    isPresented: isPresented
                )
            )
    }

    func containerView<Content: View>(
        in overlayContainer: String,
        configuration: ContainerViewConfigurationProtocol,
        isPresented: Binding<Bool>,
        content: Content
    ) -> some View {
        self
            .modifier(
                ShowContainerViewModifier(
                    container: overlayContainer,
                    content: content,
                    configuration: configuration,
                    isPresented: isPresented
                )
            )
    }

    /// Sends a view to specific overlay container when the binding to the boolean you provide is true.
    ///
    ///     struct ContentView: View {
    ///         @State var show = false
    ///         var body: some View {
    ///             VStack{
    ///                 Button("push view by isPresented"){
    ///                     show.toggle()
    ///                 }
    ///         }
    ///         .containerView(in: "container1", isPresented: $show,content: MessageView())
    ///     }
    ///
    func containerView<Content: ContainerView>(
        in overlayContainer: String,
        isPresented: Binding<Bool>,
        content: Content
    ) -> some View {
        self
            .modifier(
                ShowContainerViewModifier(
                    container: overlayContainer,
                    content: content,
                    configuration: content,
                    isPresented: isPresented
                )
            )
    }
}
