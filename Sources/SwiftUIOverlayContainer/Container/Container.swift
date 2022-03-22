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
    /// Adds the overlay container with the specified name to the current view
    /// - Parameters:
    ///   - containerName: The name of overlay container
    ///   - containerConfiguration: container configuration
    ///   - alignment: Alignment of container ( does not apply to contents in container )
    ///   - size: The size of container. The size is the maximum between the same size as its attached view or the size of the view inside the container, if kept at nil
    func overlayContainer(
        _ containerName: String,
        containerConfiguration: ContainerConfigurationProtocol,
        alignment: Alignment = .center,
        size: CGSize? = nil
    ) -> some View {
        modifier(
            SwiftUIOverlayContainerModifier(
                containerName: containerName,
                configuration: containerConfiguration,
                alignment: alignment,
                size: size
            )
        )
    }
}

/// A view modifier for wrapping the overlay container view
struct SwiftUIOverlayContainerModifier: ViewModifier {
    /// Get a container manager from SwiftUI environment
    @Environment(\.overlayContainerManager) var manager
    /// Container configuration
    let configuration: ContainerConfigurationProtocol
    /// The name of container
    let containerName: String
    /// Alignment of container ( does not apply to contents in container )
    let alignment: Alignment
    /// Size of container
    ///
    /// The size is the maximum between the same size as its attached view or the size of the view inside the container, if kept at nil
    let size: CGSize?
    init(
        containerName: String,
        configuration: ContainerConfigurationProtocol,
        alignment: Alignment = .center,
        size: CGSize? = nil
    ) {
        self.containerName = containerName
        self.configuration = configuration
        self.alignment = alignment
        self.size = size
    }

    func body(content: Content) -> some View {
        content
            .overlay(
                OverlayContainer(containerName: containerName, configuration: configuration, containerManager: manager)
                    .frame(width: size?.width, height: size?.height),
                alignment: alignment
            )
    }
}

/// The SwiftUI overlay container view.
///
/// Receive the command from container manager, show or dismiss views according the configuration
struct OverlayContainer: View {
    /// Container configuration
    let configuration: ContainerConfigurationProtocol
    /// The name of container
    let containerName: String
    /// The handler that communicate with container manager, receive commands and manage view queues.
    @StateObject var queueHandler: ContainerQueueHandler
    /// A state value that records the frame information of the container, which will be sent to the container view through the environment value
    @State var containerFrame: CGRect = .zero

    init(containerName: String, configuration: ContainerConfigurationProtocol, containerManager: ContainerManager) {
        self.containerName = containerName
        self.configuration = configuration
        let handler = ContainerQueueHandler(
            container: containerName,
            containerManager: containerManager,
            queueType: configuration.queueType,
            animation: configuration.animation,
            delayForShowingNext: configuration.delayForShowingNext,
            maximumNumberOfViewsInMultiple: configuration.maximumNumberOfViewsInMultipleMode
        )
        _queueHandler = StateObject(wrappedValue: handler)
    }

    var body: some View {
        GeometryReader { _ in
            switch configuration.displayType {
            case .stacking:
                GenericStack(displayType: configuration.displayType, alignment: .center) {
                    ForEach(queueHandler.mainQueue.alignment(displayType: .stacking, by: .center), id: \.id) { identifiableView in

                        let appearAction: () -> Void = {
                            identifiableView.configuration.appearAction?()
                            configuration.appearAction?()
                        }

                        let disappearAction: () -> Void = {
                            identifiableView.configuration.disappearAction?()
                            configuration.disappearAction?()
                        }

                        compositeContainerView(
                            for: identifiableView,
                            containerConfiguration: configuration,
                            queueHandler: queueHandler,
                            containerName: containerName,
                            containerFrame: containerFrame
                        )
                        .onAppear(perform: appearAction)
                        .onDisappear(perform: disappearAction)
                    }
                }
            case .vertical, .horizontal:
                let alignment = Alignment.merge(
                    containerAlignment: configuration.alignment, viewAlignment: nil, containerViewDisplayType: configuration.displayType
                )
                let background = compositeContainerBackground(containerConfiguration: configuration, queueHandler: queueHandler)
                let insets = configuration.insets

                ZStack(alignment: alignment) {
                    Group {
                        if !queueHandler.mainQueue.isEmpty {
                            background
                        }
                    }
                    .zIndex(1.0)

                    GenericStack(displayType: configuration.displayType, alignment: alignment, spacing: configuration.spacing) {
                        ForEach(queueHandler.mainQueue.alignment(
                            displayType: configuration.displayType, by: alignment
                        ), id: \.id) { identifiableView in

                            let appearAction: () -> Void = {
                                identifiableView.configuration.appearAction?()
                                configuration.appearAction?()
                            }

                            let disappearAction: () -> Void = {
                                identifiableView.configuration.disappearAction?()
                                configuration.disappearAction?()
                            }

                            compositeContainerView(
                                for: identifiableView,
                                containerConfiguration: configuration,
                                queueHandler: queueHandler,
                                containerName: containerName,
                                containerFrame: containerFrame
                            )
                            .onAppear(perform: appearAction)
                            .onDisappear(perform: disappearAction)
                        }
                    }
                    .padding(insets)
                    .zIndex(2.0)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
        }
        .recordCurrentViewFrameInfo(to: $containerFrame)
        .onAppear { queueHandler.connect() }
        .onDisappear { queueHandler.disconnect() }
        // if animation or delayForShowingNext changed, reassign the properties of queueHandler
        // The queue handler has the ability to respond to the container configuration changes
        .onChange(of:
            configuration.animation,
            configuration.delayForShowingNext,
            configuration.maximumNumberOfViewsInMultipleMode) { newAnimation, newDelay, newMaximumNumberOfViewsInMultipleMode in
                queueHandler.animation = newAnimation
                queueHandler.delayForShowingNext = newDelay
                queueHandler.maximumNumberOfViewsInMultiple = newMaximumNumberOfViewsInMultipleMode
        }
        // Prohibition of changing the containerName and the queueType
        .onChange(of: configuration.queueType, containerName, configuration.clipped) { _ in
            #if DEBUG
            fatalError("❌ Can't change container name,queue type and clipped in runtime, this message only show in Debug mode.")
            #endif
        }
        .clipped(enable: configuration.clipped)
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
    @Environment(\.overlayContainerManager) var manager
    @State var show = false
    var body: some View {
        VStack {
            Button("Show message in container1") {
                manager.show(containerView: MessageView(), in: "container1")
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .overlayContainer("container1", containerConfiguration: ContainerConfiguration())
    }
}

struct MessageView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(.orange)
            .frame(height: 100)
            .padding(.horizontal, 20)
            .overlay(Text("Hello World"))
    }
}

extension MessageView: ContainerViewConfigurationProtocol {
    var shadowStyle: ContainerViewShadowStyle? {
        .radius(10)
    }
}

struct ContainerConfiguration: ContainerConfigurationProtocol {
    var displayType: ContainerViewDisplayType = .vertical

    var queueType: ContainerViewQueueType = .oneByOne

    var spacing: CGFloat { 10 }

    var transition: AnyTransition? {
        .move(edge: .bottom).combined(with: .opacity)
    }

    var dismissGesture: ContainerViewDismissGesture? {
        .tap
    }

    var animation: Animation? {
        .easeInOut
    }

    var backgroundStyle: ContainerBackgroundStyle? {
        .color(.gray.opacity(0.3))
    }

    var tapToDismiss: Bool? {
        true
    }

    var insets: EdgeInsets {
        .init(top: 0, leading: 0, bottom: 30, trailing: 0)
    }
}
#endif
