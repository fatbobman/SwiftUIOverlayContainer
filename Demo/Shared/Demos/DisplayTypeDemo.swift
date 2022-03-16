//
//  DisplayTypeDemo.swift
//  Demo
//
//  Created by Yang Xu on 2022/3/16
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import SwiftUI
import SwiftUIOverlayContainer

struct DisplayTypeDemo: View {
    @State var displayType: ContainerViewDisplayType = .stacking
    @State var spacing: Double = 10
    @State var containerConfiguration = DisplayTypeContainerConfiguration()
    @State var viewConfiguration = DisplayTypeViewConfiguration()
    @Environment(\.overlayContainerManager) var manager
    var body: some View {
        ZStack(alignment: .top) {
            Color(grayColor)
            VStack {
                Text("DisplayTypeDescription")
                    .padding(.all, 20)
                Picker("DisplayTypeLinkLabel", selection: $displayType) {
                    ForEach(ContainerViewDisplayType.allCases) { displayType in
                        Text(displayType.information.name)
                            .tag(displayType)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .onChange(of: displayType, perform: { type in
                    reset()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        switch type {
                        case .horizontal:
                            containerConfiguration = .horizontal
                            viewConfiguration = .horizontal
                        case .vertical:
                            containerConfiguration = .vertical
                            viewConfiguration = .vertical
                        case .stacking:
                            containerConfiguration = .stacking
                            viewConfiguration = .stacking
                        }
                    }
                })

                Text(displayType.information.description)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: 500)
                    .padding(.init(top: 30, leading: 30, bottom: 20, trailing: 30))

                VStack {
                    Button {
                        manager.show(view: generateContainerView(), in: "DisplayTypeContainer", using: viewConfiguration)
                    } label: {
                        Text("AddBlockButton")
                            .textCase(.uppercase)
                    }

                    Text("PushButtonTip")
                }
                .buttonStyle(.bordered)
                .padding(.bottom, 30)

                adjustmentView()

                moreDetailView()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle("DisplayTypeTitle")
        #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .overlayContainer("DisplayTypeContainer", containerConfiguration: containerConfiguration)
    }
}

extension DisplayTypeDemo {
    func generateContainerView() -> some View {
        var size: CGSize = .zero
        var text: LocalizedStringKey = ""
        var opacity = 0.8
        var offset: CGSize = .zero
        switch displayType {
        case .stacking:
            offset = .init(width: CGFloat.random(in: -30...30), height: CGFloat.random(in: -30...30) + 100)
            opacity = 0.6
            text = "DismissForStacking"
            size = .init(width: 100, height: 100)
        case .vertical:
            text = "DismissForVertical"
            size = .init(width: 300, height: 60)
        case .horizontal:
            text = "DismissForHorizontal"
            size = .init(width: 70, height: 120)
            offset = .init(width: 0, height: 200)
        }
        return BlockView(size: size, text: text, opacity: opacity)
            .offset(offset)
    }

    func reset() {
        manager.dismissAllView(in: ["DisplayTypeContainer"], animated: true)
        spacing = 10
    }

    @ViewBuilder
    func sliderOfSpacing() -> some View {
        VStack {
            Text("SliderOfSpace \(String(format: "%.1f", spacing))")
            Slider(value: $spacing, in: -20.0...30)
                .onChange(of: spacing, perform: { value in
                    containerConfiguration.spacing = value
                })
        }
        .padding(.horizontal, 30)
    }

    @ViewBuilder
    func adjustmentView() -> some View {
        switch displayType {
        case .vertical, .horizontal:
            sliderOfSpacing()
                .padding()
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    func moreDetailView() -> some View {
        Text("ContainerMoreInfo")
            .padding(.horizontal, 20)
    }
}

struct DisplayTypeDemo_Previews: PreviewProvider {
    static var previews: some View {
        DisplayTypeDemo()
            .previewLayout(.sizeThatFits)
    }
}

extension ContainerViewDisplayType: Information {
    var information: (name: String, description: LocalizedStringKey) {
        switch self {
        case .horizontal:
            return ("horizontal", "HorizontalDescription")
        case .vertical:
            return ("vertical", "VerticalDescription")
        case .stacking:
            return ("stacking", "StackingDescription")
        }
    }
}

extension ContainerViewDisplayType: Identifiable {
    public var id: String {
        information.name
    }
}

extension ContainerViewDisplayType: CaseIterable {
    public static var allCases: [ContainerViewDisplayType] = [
        .stacking,
        .horizontal,
        .vertical
    ]
}

struct DisplayTypeContainerConfiguration: ContainerConfigurationProtocol {
    var displayType: ContainerViewDisplayType = .stacking
    var queueType: ContainerViewQueueType { .multiple }
    var alignment: Alignment? = .center
    var spacing: CGFloat = 10
    var insets: EdgeInsets = .init()

    var shadowStyle: ContainerViewShadowStyle? {
        .radius(10)
    }

    static let stacking: DisplayTypeContainerConfiguration = .init(displayType: .stacking, alignment: .center, spacing: 10, insets: .init())
    static let horizontal: DisplayTypeContainerConfiguration = .init(displayType: .horizontal, alignment: .leading, spacing: 10, insets: .init(top: 0, leading: 20, bottom: 0, trailing: 0))
    static let vertical: DisplayTypeContainerConfiguration = .init(displayType: .vertical, alignment: .bottom, spacing: 10, insets: .init(top: 0, leading: 0, bottom: 20, trailing: 0))
}

struct DisplayTypeViewConfiguration: ContainerViewConfigurationProtocol {
    var alignment: Alignment? = .center
    var transition: AnyTransition? = .opacity
    var dismissGesture: ContainerViewDismissGesture? = .tap

    static let stacking: DisplayTypeViewConfiguration = .init(alignment: .center, transition: .opacity, dismissGesture: .tap)
    static let horizontal: DisplayTypeViewConfiguration = .init(alignment: nil, transition: .move(edge: .leading).combined(with: .opacity), dismissGesture: .swipeLeft)
    static let vertical: DisplayTypeViewConfiguration = .init(alignment: nil, transition: .move(edge: .bottom).combined(with: .opacity), dismissGesture: .swipeDown)
}
