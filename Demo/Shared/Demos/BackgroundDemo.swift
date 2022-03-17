//
//  BackgroundDemo.swift
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

struct BackgroundDemo: View {
    @Environment(\.overlayContainerManager) var manager
    @State var tapToDismiss = true
    var body: some View {
        ZStack {
            Color.clear
            VStack {
                VStack {
                    ForEach(backgrounds) { background in
                        Button(action: {
                            let viewConfiguration = BackgroundDemoViewConfiguration(tapToDismiss: tapToDismiss, backgroundStyle: background.background)
                            let size = CGSize(width: 300, height: 400)
                            let view = BlockView(size: size, text: background.description, opacity: 1, allowDismiss: false)
                            manager.show(view: view, in: "backgroundContainer", using: viewConfiguration)
                        }, label: {
                            Text(background.description)
                                .frame(width: 250)
                        })
                        .buttonStyle(.bordered)
                    }

                    Toggle("TapToDismiss", isOn: $tapToDismiss)
                        .toggleStyle(.automatic)
                        .padding(.vertical,20)
                        .padding(.horizontal,50)

                }
                .padding(.top, 50)
                Spacer()
                VStack {
                    Text("ViewBackgroundDescription")
                        .padding(.horizontal,30)
                }
                .padding(.bottom,300)
            }
        }
        .background(LinearGradient(colors: [.blue, .cyan, .green], startPoint: .top, endPoint: .bottom).opacity(0.5))
        .overlayContainer("backgroundContainer", containerConfiguration: BackgroundContainerConfiguration())
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle("ViewBackgroundLabel")
        #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

extension BackgroundDemo {
    var backgrounds: [ViewBackground] {
        [
            .init(description: "BlurBackground", background: .blur(.ultraThin)),
            .init(description: "ColorBackground", background: .color(.indigo.opacity(0.8))),
            .init(description: "ViewBackground", background: .view(backgroundView.eraseToAnyView())),
            .init(description: "DisableBackground", background: .disable)
        ]
    }

    @ViewBuilder
    var backgroundView: some View {
        ZStack {
            LinearGradient(colors: [.blue, .cyan, .green], startPoint: .top, endPoint: .bottom)
            Image("tilePic")
                .resizable(resizingMode: .tile)
        }
    }
}

struct ViewBackground: Identifiable {
    let id = UUID()
    let description: LocalizedStringKey
    let background: ContainerBackgroundStyle
}

struct BackgroundDemo_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundDemo()
    }
}

struct BackgroundContainerConfiguration: ContainerConfigurationProtocol {
    var displayType: ContainerViewDisplayType { .stacking }
    var queueType: ContainerViewQueueType { .oneByOne }
    var alignment: Alignment? { .center }
    var transition: AnyTransition? { .scale.combined(with: .opacity) }
    var dismissGesture: ContainerViewDismissGesture? {
        .tap
    }



    var shadowStyle: ContainerViewShadowStyle? {
        .radius(10)
    }
}

struct BackgroundDemoViewConfiguration: ContainerViewConfigurationProtocol {
    let tapToDismiss: Bool?
    var backgroundStyle: ContainerBackgroundStyle?
    var animation: Animation?{.easeInOut}
}
