//
//  ControllableAnimationDemo.swift
//  Demo
//
//  Created by Yang Xu on 2022/3/17
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import SwiftUI
import SwiftUIOverlayContainer

struct ControllableAnimationDemo: View {
    @Environment(\.overlayContainerManager) var manager
    let container = "animationContainer"
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue, .cyan, .green], startPoint: .top, endPoint: .bottom).opacity(0.5)
            VStack {
                VStack {
                    Button {
                        let view = BlockView(size: .init(width: 300, height: 80), text: "ShowWithAnimation", opacity: 0.8)
                        manager.show(view: view, in: container, using: AnimatedViewConfiguration())

                    } label: {
                        Text("ShowWithAnimation")
                            .frame(width: 300)
                    }
                    Button {
                        let view = BlockView(size: .init(width: 300, height: 80), text: "ShowWithoutAnimation", opacity: 0.8)
                        manager.show(view: view, in: container, using: AnimatedViewConfiguration(), animated: false)

                    } label: {
                        Text("ShowWithoutAnimation")
                            .frame(width: 300)
                    }
                    Button {
                        manager.dismissAllView(in: [container], animated: true)
                    } label: {
                        Text("DismissWithoutAnimation")
                            .frame(width: 300)
                    }
                    Button {
                        manager.dismissAllView(in: [container], animated: false)
                    } label: {
                        Text("DismissWithoutAnimation")
                            .frame(width: 300)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 100)
                .buttonStyle(.bordered)
                Spacer()
                VStack {
                    Text("ControllableAnimationDescription")
                        .padding(.horizontal, 30)
                }
                .padding(.bottom, 300)
            }
        }
        .overlayContainer(container, containerConfiguration: AnimatedContainerConfiguration())
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle("ControllableAnimationLabel")
        #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct ControllableAnimationDemo_Previews: PreviewProvider {
    static var previews: some View {
        ControllableAnimationDemo()
    }
}

struct AnimatedContainerConfiguration: ContainerConfigurationProtocol {
    var displayType: ContainerViewDisplayType = .vertical
    var queueType: ContainerViewQueueType = .multiple
    var dismissGesture: ContainerViewDismissGesture? { .tap }
    var alignment: Alignment? { .bottom }
    var transition: AnyTransition? { .move(edge: .bottom).combined(with: .opacity) }
    var insets: EdgeInsets {
        .init(top: 0, leading: 0, bottom: 20, trailing: 0)
    }
}

struct AnimatedViewConfiguration: ContainerViewConfigurationProtocol {}
