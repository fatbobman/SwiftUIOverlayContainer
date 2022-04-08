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

/// A struct that wraps SwiftUI view with Identifier
public struct IdentifiableContainerView: Identifiable {
    /// The identifier for view, used to identifier which view should be dismiss and the identifier of `ForEach`
    public let id: UUID

    /// View for Container, convert any kind SwiftUI view to anyView type
    let view: AnyView

    /// Configuration of container View
    let configuration: ContainerViewConfigurationProtocol

    /// A bind value that controls the display of the current container view, set false to dismiss the current view
    let isPresented: Binding<Bool>?

    /// The timestamp of push to display queue, used as a reference for zIndex
    var timeStamp = Date()

    public init<Context: View>(
        id: UUID,
        view: Context,
        viewConfiguration: ContainerViewConfigurationProtocol,
        isPresented: Binding<Bool>? = nil
    ) {
        self.id = id
        self.view = view.eraseToAnyView()
        self.configuration = viewConfiguration
        self.isPresented = isPresented
    }
}

#if DEBUG
struct IdentifiableViewPreview: PreviewProvider {
    static var previews: some View {
        IdentifiableContainerView(id: UUID(), view: CellView(), viewConfiguration: CellView(), isPresented: nil)
            .view
    }
}

struct CellView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.orange)
            .padding(.horizontal, 20)
            .frame(height: 50)
            .overlay(Text("Hello world"))
    }
}

extension CellView: ContainerViewConfigurationProtocol {}
#endif
