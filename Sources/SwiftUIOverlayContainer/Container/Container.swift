//
//  Contianer.swift
//
//
//  Created by Yang Xu on 2022/3/5
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation
import SwiftUI

public extension View {
    func overlayContainer(_ containerName: String, containerConfiguration: ContainerConfigurationProtocol) -> some View {
        modifier(SwiftUIOverlayContainerModifier(containerName: containerName, configuration: containerConfiguration))
    }
}

struct SwiftUIOverlayContainerModifier: ViewModifier {
    @Environment(\.overlayContainerManager) var manager
    let configuration: ContainerConfigurationProtocol
    let containerName: String
    init(containerName: String, configuration: ContainerConfigurationProtocol) {
        self.containerName = containerName
        self.configuration = configuration
    }

    func body(content: Content) -> some View {
        content
            .overlay(OverlayContainer(containerName: containerName, configuration: configuration, containerManager: manager))
    }
}

struct OverlayContainer: View {
    let configuration: ContainerConfigurationProtocol
    let containerName: String
    @StateObject var queueHandler: ContainerQueueHandler
    @State var containerFrame: CGRect = .zero

    init(containerName: String, configuration: ContainerConfigurationProtocol, containerManager: ContainerManager) {
        self.containerName = containerName
        self.configuration = configuration
        let handler = ContainerQueueHandler(
            container: containerName,
            containerConfiguration: configuration,
            containerManager: containerManager
        )
        _queueHandler = StateObject(wrappedValue: handler)
    }

    var body: some View {
        Group {
            switch configuration.displayType {
            case .stacking:
                GenericStack(displayType: configuration.displayType, alignment: .center) {
                    ForEach(queueHandler.mainQueue.alignment(displayType: .stacking, by: .center), id: \.id) { identifiableView in
                        compositeContainerView(for: identifiableView, containerConfiguration: configuration, queueHandler: queueHandler)
                    }
                }
            case .vertical, .horizontal:
                let alignment = Alignment.merge(
                    containerAlignment: configuration.alignment, viewAlignment: nil, containerViewDisplayType: configuration.displayType
                )
                let dismissAction = compositeDismissActionForAllViewIsShowing(containerConfiguration: configuration, queueHandler: queueHandler)
                let background = compositeContainerBackground(containerConfiguration: configuration, dismissAction: dismissAction)
                let insets = configuration.insets

                ZStack(alignment: alignment) {
                    if !queueHandler.mainQueue.isEmpty {
                        background
                    }

                    GenericStack(displayType: configuration.displayType, alignment: alignment) {
                        ForEach(queueHandler.mainQueue.alignment(
                            displayType: configuration.displayType, by: alignment
                        ), id: \.id) { identifiableView in
                            compositeContainerView(for: identifiableView, containerConfiguration: configuration, queueHandler: queueHandler)
                                .padding(insets)
                        }
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
        }
        .getCurrentViewFrameInfo(to: $containerFrame)
        .onAppear { queueHandler.connect() }
        .onDisappear { queueHandler.disconnect() }
    }
}

#if DEBUG
struct ContainerPreview: PreviewProvider {
    static var previews: some View {
        RootView()
            .previewLayout(.fixed(width: 400, height: 700))
    }
}

struct RootView: View {
    @State var show = false
    var body: some View {
        VStack {
            Text("Hello")
            Button("show view1") {
                show.toggle()
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .overlayContainer("container1", containerConfiguration: ContainerConfiguration())
        .containerView(in: "container1", isPresented: $show, content: MessageView())
    }
}

struct MessageView: View {
    var body: some View {
        Text("abc")
    }
}

extension MessageView: ContainerViewConfigurationProtocol {}

struct ContainerConfiguration: ContainerConfigurationProtocol {
    var displayType: ContainerViewDisplayType = .vertical
    var queueType: ContainerViewQueueType = .oneByOne
}
#endif
