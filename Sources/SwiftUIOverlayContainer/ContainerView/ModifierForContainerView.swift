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

/// Show the view in the specific overlay container when the bind value is true.
struct ShowContainerViewModifier<V: View>: ViewModifier {
    let container: String
    var view: V
    let animated: Bool
    let configuration: ContainerViewConfigurationProtocol
    @Binding var isPresented: Bool
    @Environment(\.overlayContainerManager) var containerManager
    @State var identifiableViewID: UUID?

    init(container: String, view: V, configuration: ContainerViewConfigurationProtocol, isPresented: Binding<Bool>, animated: Bool) {
        self.container = container
        self.view = view
        self.configuration = configuration
        self._isPresented = isPresented
        self.animated = animated
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { _ in
                if isPresented {
                    identifiableViewID = containerManager._show(
                        view: view,
                        in: container,
                        using: configuration,
                        isPresented: $isPresented
                    )
                } else {
                    if let identifiableViewID = identifiableViewID {
                        containerManager.dismiss(view: identifiableViewID, in: container, animated: animated)
                    }
                }
            }
    }
}

public extension View {
    /// Show the view in the specific overlay container when the binding value is true.
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
    /// When the view is dismissed by any means, the bind value will be set to false
    func containerView<Content: View>(
        in overlayContainer: String,
        configuration: ContainerViewConfigurationProtocol,
        isPresented: Binding<Bool>,
        animated: Bool = true,
        @ViewBuilder content: () -> Content
    ) -> some View {
        self
            .modifier(
                ShowContainerViewModifier(
                    container: overlayContainer,
                    view: content(),
                    configuration: configuration,
                    isPresented: isPresented,
                    animated: animated
                )
            )
    }

    /// Show the view in the specific overlay container when the bind value is true.
    ///
    /// When the view is dismissed by any means, the bind value will be set to false
    func containerView<Content: View>(
        in overlayContainer: String,
        configuration: ContainerViewConfigurationProtocol,
        isPresented: Binding<Bool>,
        animated: Bool = true,
        content: Content
    ) -> some View {
        self
            .modifier(
                ShowContainerViewModifier(
                    container: overlayContainer,
                    view: content,
                    configuration: configuration,
                    isPresented: isPresented,
                    animated: animated
                )
            )
    }

    /// Show the view in the specific overlay container when the bind value is true.
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
    /// When the view is dismissed by any means, the bind value will be set to false
    func containerView<Content: ContainerView>(
        in overlayContainer: String,
        isPresented: Binding<Bool>,
        animated: Bool = true,
        content: Content
    ) -> some View {
        self
            .modifier(
                ShowContainerViewModifier(
                    container: overlayContainer,
                    view: content,
                    configuration: content,
                    isPresented: isPresented,
                    animated: animated
                )
            )
    }
}
