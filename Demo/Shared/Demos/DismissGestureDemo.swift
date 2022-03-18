//
//  DismissGestureDemo.swift
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

struct DismissGestureDemo: View {
    @Environment(\.overlayContainerManager) var manager
    var body: some View {
        ZStack {
            Color(backgroundColorOfZStack)
            VStack {
                VStack {
                    ForEach(gestures) { dismissGesture in
                        Button(action: {
                            let configuration = GestureViewConfiguration(dismissGesture: dismissGesture.gesture)
                            let view = BlockView(
                                size: .init(width: 200, height: 80),
                                text: dismissGesture.description,
                                opacity: 0.7,
                                allowDismiss: false
                            )
                            manager.show(view: view, in: "gestureContainer", using: configuration)
                        }, label: {
                            Text(dismissGesture.description)
                                .frame(width: 200)
                        })
                    }
                }
                .padding(.top, 50)
                .buttonStyle(.bordered)
                .controlSize(.large)
                ViewContainer("gestureContainer", configuration: GestureContainer())
                VStack {
                    Text("DismissGestureDescription")
                }
                .padding(.init(top: 0, leading: 20, bottom: 40, trailing: 20))
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle("DismissGestureLabel")
        #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

extension DismissGestureDemo {
    var gestures: [DismissGesture] {
        [
            .init(gesture: .tap, description: "TapGesture"),
            .init(gesture: .doubleTap, description: "DoubleTapGesture"),
            .init(gesture: .longPress(0.5), description: "LongPressGesture"),
            .init(gesture: .swipeUp, description: "SwipeUpGesture"),
            .init(gesture: .swipeLeft, description: "SwipeLeftGesture"),
            .init(gesture: .swipeRight, description: "SwipeRightGesture"),
            .init(gesture: .swipeDown, description: "SwipeDownGesture")
        ]
    }
}

struct DismissGesture: Identifiable {
    let id = UUID()
    let description: LocalizedStringKey
    let gesture: ContainerViewDismissGesture

    init(gesture: ContainerViewDismissGesture, description: LocalizedStringKey) {
        self.gesture = gesture
        self.description = description
    }
}

struct DismissGestureDemo_Previews: PreviewProvider {
    static var previews: some View {
        DismissGestureDemo()
    }
}

struct GestureContainer: ContainerConfigurationProtocol {
    var displayType: ContainerViewDisplayType = .stacking
    var queueType: ContainerViewQueueType = .oneByOne
    var alignment: Alignment? = .center
    var transition: AnyTransition? = .slide
    var animation: Animation? = .default
}

struct GestureViewConfiguration: ContainerViewConfigurationProtocol {
    var dismissGesture: ContainerViewDismissGesture?
}
