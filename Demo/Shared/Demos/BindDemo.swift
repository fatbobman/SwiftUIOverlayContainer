//
//  BindDemo.swift
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

struct BindDemo: View {
    @Environment(\.overlayContainerManager) var manager
    @State var showA = false
    @State var showB = false
    let container = "bindValueContainer"
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue, .cyan, .green], startPoint: .top, endPoint: .bottom).opacity(0.5)
            VStack {
                VStack {
                    buttonGroup(view: "A", isPresented: $showA)
                    buttonGroup(view: "B", isPresented: $showB)
                }
                .padding(.horizontal, 30)
                .padding(.top, 100)
                .buttonStyle(.bordered)
                Spacer()
                VStack {
                    Text("BindValueDescription")
                        .padding(.horizontal, 30)
                }
                .padding(.bottom, 300)
            }
        }
        .overlayContainer(container, containerConfiguration: BindDemoContainerConfiguration())
        .containerView(in: container, configuration: configA, isPresented: $showA, content: viewA)
        .containerView(in: container, configuration: configB, isPresented: $showB, content: viewB)
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle("BindValueLabel")
        #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    @ViewBuilder
    func buttonGroup(view: String, isPresented: Binding<Bool>) -> some View {
        GroupBox {
            VStack {
                Button {
                    isPresented.wrappedValue.toggle()
                } label: {
                    if isPresented.wrappedValue {
                        Text("Dismiss \(view)")
                    } else {
                        Text("Show \(view)")
                    }
                }
                .textCase(.uppercase)
                Text("IsPresentedStatus \(view) \(isPresented.wrappedValue ? "True" : "False")")
            }
            .frame(width: 300)
        }
    }

    @ViewBuilder
    var viewA: some View {
        let size = CGSize(width: 200, height: 250)
        BlockView(size: size, text: "View \("A")", opacity: 0.6)
    }

    var configA: ContainerViewConfigurationProtocol {
        BindDemoViewConfiguration(alignment: .bottomLeading, transition: .move(edge: .leading))
    }

    @ViewBuilder
    var viewB: some View {
        let size = CGSize(width: 200, height: 250)
        BlockView(size: size, text: "View \("B")", opacity: 0.6)
    }

    var configB: ContainerViewConfigurationProtocol {
        BindDemoViewConfiguration(alignment: .bottomTrailing, transition: .move(edge: .trailing))
    }
}

struct BindDemo_Previews: PreviewProvider {
    static var previews: some View {
        BindDemo()
    }
}

struct BindDemoContainerConfiguration: ContainerConfigurationProtocol {
    var displayType: ContainerViewDisplayType = .stacking
    var queueType: ContainerViewQueueType = .multiple
    var dismissGesture: ContainerViewDismissGesture? { .tap }
    var insets: EdgeInsets { .init(top: 0, leading: 50, bottom: 100, trailing: 50) }
}

struct BindDemoViewConfiguration: ContainerViewConfigurationProtocol {
    var alignment: Alignment?
    var transition: AnyTransition?
}
