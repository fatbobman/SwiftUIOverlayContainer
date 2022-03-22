//
//  CustomMenuDemo.swift
//  Demo
//
//  Created by Yang Xu on 2022/3/21
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation
import SwiftUI
import SwiftUIOverlayContainer

struct CustomMenuDemo: View {
    @State var transitionType = 0
    @Namespace var menu
    let container = "menuContainer"

    let button1 = "button1"
    let button2 = "button2"
    @State var showButton1 = false
    @State var showButton2 = false

    var body: some View {
        ZStack {
            Color(backgroundColorOfZStack)
            VStack {
                // select transition
                Picker("", selection: $transitionType) {
                    Text("Transition1")
                        .tag(0)
                    Text("Transition2")
                        .tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                HStack {
                    // Button1
                    Button {
                        showButton1.toggle()
                    } label: {
                        Text("PopMenu")
                            .textCase(.uppercase)
                    }
                    .buttonStyle(.bordered)
                    .matchedGeometryEffect(id: button1, in: menu, properties: .position, anchor: .bottom, isSource: true)
                    .containerView(
                        in: container,
                        isPresented: $showButton1,
                        content: MenuView(
                            isPresented: $showButton1,
                            transitionType: transitionType,
                            namespace: menu,
                            id: button1,
                            anchor: .top
                        )
                    )
                }

                Spacer()
                Text("CustomMenuDescription")
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
            }
            .frame(maxHeight: 300)
            #if targetEnvironment(macCatalyst) || !os(macOS)
                // In macOS, the container view displayed abnormally when positioned to the toolbar via matchedGeometryEffect.
                .toolbar {
                    // Button2
                    Button {
                        showButton2.toggle()
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                    }
                    .matchedGeometryEffect(id: button2, in: menu, properties: .position, anchor: .bottomTrailing, isSource: true)
                    .containerView(
                        in: container,
                        isPresented: $showButton2,
                        content: MenuView(
                            isPresented: $showButton2,
                            transitionType: transitionType,
                            namespace: menu,
                            id: button2,
                            anchor: .topTrailing
                        )
                    )
                }
            #endif
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle("CustomMenuLabel")
        .overlayContainer(container, containerConfiguration: MenuContainerConfiguration())
        #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct MenuView: View {
    @Binding var isPresented: Bool
    let transitionType: Int
    let namespace: Namespace.ID
    let id: String
    let anchor: UnitPoint

    var dismiss: () -> Void {
        { isPresented = false }
    }

    let icons = ["cloud.fill", "cloud.drizzle.fill", "cloud.fog.fill", "cloud.bolt.fill", "smoke.fill"]
    var count: Int { icons.count }
    var body: some View {
        VStack {
            ForEach(0..<count, id: \.self) { i in
                Button {
                    print("do action of item: \(i)")
                    dismiss()
                } label: {
                    HStack {
                        Text("Item \(i)")
                        Spacer()
                        Image(systemName: icons[i])
                    }
                    .padding(.horizontal, 20)
                    .contentShape(Rectangle())
                }
                if i < (count - 1) {
                    Divider()
                } else {
                    Divider()
                        .hidden()
                }
            }
            .foregroundColor(.primary)
            #if os(macOS) && !targetEnvironment(macCatalyst)
                .buttonStyle(PlainButtonStyle())
            #endif
        }
        .padding(.top, 10)
        .frame(width: 150)
        .background(Color.white)
        .padding(.top, 10)
        .matchedGeometryEffect(id: id, in: namespace, properties: .position, anchor: anchor, isSource: false)
    }
}

struct MenuContainerConfiguration: ContainerConfigurationProtocol {
    let displayType: ContainerViewDisplayType = .stacking
    let queueType: ContainerViewQueueType = .oneByOne
    let alignment: Alignment? = .top
    // Set to true to prevent the menu (for button2) in the toolbar from displaying abnormally when the transition is scale
    let clipped = true

    var shadowStyle: ContainerViewShadowStyle? {
        .radius(10)
    }
}

extension MenuView: ContainerViewConfigurationProtocol {
    var transitions: [AnyTransition] {
        [
            // Setting it to zero will produce a lot of warning messages
            .scale(scale: 0.01, anchor: .top).combined(with: .opacity),
            .opacity
        ]
    }

    var transition: AnyTransition? {
        transitions[transitionType]
    }

    var backgroundStyle: ContainerBackgroundStyle? {
        // for tapToDismiss
        .color(Color.white.opacity(0.01))
    }

    var tapToDismiss: Bool? {
        true
    }
}

#if DEBUG
struct CustomMenuPreview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CustomMenuDemo()
        }
    }
}
#endif
