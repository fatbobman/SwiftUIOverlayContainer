//
//  ViewConfigurationDemo.swift
//  Demo
//
//  Created by Yang Xu on 2022/3/17
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//
// swiftlint:disable identifier_name
// swiftlint:disable type_name

import SwiftUI
import SwiftUIOverlayContainer

struct ViewConfigurationDemo: View {
    @Environment(\.overlayContainerManager) var manager
    var body: some View {
        ZStack(alignment: .top) {
            Color(backgroundColorOfZStack)
            VStack {
                ViewContainer("viewDemo", configuration: .viewConfigurationDemo)
                    .frame(minHeight: 300)
                Text("ViewConfigurationDescription")
                    .padding()
                VStack {
                    Button {
                        manager.show(view: generateContainerView(), in: "viewDemo", using: .randomConfiguration)
                    } label: {
                        Text("CreateNewRandomView")
                            .textCase(.uppercase)
                    }
                    .padding(.bottom, 20)
                }
                .buttonStyle(.bordered)
                .padding(.bottom, 30)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle("ViewConfigurationLabel")
        #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    func generateContainerView() -> some View {
        let size: CGSize = .init(width: CGFloat.random(in: 120...150), height: CGFloat.random(in: 70...120))
        let text: LocalizedStringKey = "AutoDismiss"
        let opacity = Double.random(in: 0.5...1.0)
        return BlockView(size: size, text: text, opacity: opacity)
    }
}

struct ViewConfigurationDemo_Previews: PreviewProvider {
    static var previews: some View {
        ViewConfigurationDemo()
    }
}

struct ViewConfigurationDemoContainerConfiguration: ContainerConfigurationProtocol {
    var queueType: ContainerViewQueueType = .oneByOne
    var displayType: ContainerViewDisplayType = .stacking

    var insets: EdgeInsets {
        .init(top: 30, leading: 30, bottom: 30, trailing: 30)
    }
}

extension ContainerConfigurationProtocol where Self == ViewConfigurationDemoContainerConfiguration {
    static var viewConfigurationDemo: ViewConfigurationDemoContainerConfiguration {
        ViewConfigurationDemoContainerConfiguration()
    }
}

class ViewConfigurationDemoContainerViewConfiguration: ContainerViewConfigurationProtocol {
    var alignment: Alignment? {
        [.leading, .topLeading, .bottomLeading, .center, .bottom, .topTrailing, .bottomTrailing, .top, .trailing].randomElement()
    }

    var shadowStyle: ContainerViewShadowStyle? {
        let color: Color = [.blue, .green, .brown, .black].randomElement() ?? .red
        let x = CGFloat.random(in: -5...5)
        let y = CGFloat.random(in: -5...5)
        let radius = CGFloat.random(in: 5...14)
        return [.radius(radius), .disable, .custom(color, 10, x, y)].randomElement()
    }

    var dismissGesture: ContainerViewDismissGesture? {
        .tap
    }

    var transition: AnyTransition? {
        let t1: AnyTransition = .opacity
        let t2: AnyTransition = .move(edge: .trailing).combined(with: .opacity)
        let t3: AnyTransition = .slide.combined(with: .opacity)
        let t4: AnyTransition = .scale.combined(with: .opacity)
        let t5: AnyTransition = .asymmetric(insertion: .move(edge: .top).combined(with: .opacity), removal: t2)
        let t6: AnyTransition = .asymmetric(insertion: t4, removal: t1)
        let t7: AnyTransition = .asymmetric(insertion: t2, removal: t4)
        return [t1, t2, t3, t4, t5, t6, t7].randomElement()
    }

    var autoDismiss: ContainerViewAutoDismiss? {
        .seconds(2)
    }

    var animation: Animation? {
        let speed = Double.random(in: 0.3...1.5)
        return [.easeIn, .easeInOut, .linear, .spring().speed(speed), .interactiveSpring()].randomElement()
    }
}

extension ContainerViewConfigurationProtocol where Self == ViewConfigurationDemoContainerViewConfiguration {
    static var randomConfiguration: ViewConfigurationDemoContainerViewConfiguration {
        ViewConfigurationDemoContainerViewConfiguration()
    }
}
