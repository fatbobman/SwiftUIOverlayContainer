//
//  QueueTypeDemo.swift
//  Demo (iOS)
//
//  Created by Yang Xu on 2022/3/16
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation
import SwiftUI
import SwiftUIOverlayContainer

struct QueueTypeDemo: View {
    @State var queueType: ContainerViewQueueType = .multiple
    @State var messageID = 1
    @State var maxNumberOfView: Double = 4
    @State var delayForNext: TimeInterval = 0.5

    @Environment(\.overlayContainerManager) var manager
    let containers = ContainerViewQueueType.allCases.map { $0.information.name }
    var body: some View {
        ZStack(alignment: .top) {
            Color.clear
            VStack {
                Text("QueueTypeDescription")
                    .padding(.all, 20)
                Picker("QueueTypeLinkLabel", selection: $queueType) {
                    ForEach(ContainerViewQueueType.allCases) { queueType in
                        Text(queueType.information.name)
                            .tag(queueType)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .onChange(of: queueType, perform: { _ in
                    reset()
                })

                Text(queueType.information.description)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: 500)
                    .padding(.init(top: 30, leading: 30, bottom: 20, trailing: 30))
                VStack {
                    Button {
                        manager.show(containerView: generateContainerView(), in: queueType.information.name)
                    } label: {
                        Text("PushOneMessage")
                            .textCase(.uppercase)
                    }
                    if messageID > 1 {
                        Text("CurrentMessageID \(messageID - 1)")
                            .transition(.opacity)
                    }

                    Text("PushButtonTip")
                }
                .buttonStyle(.bordered)
                .padding(.bottom, 30)
                adjustmentView()
            }
        }
        .background(LinearGradient(colors: [.blue, .cyan, .green], startPoint: .top, endPoint: .bottom).opacity(0.5))
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle("QueueTypeTitle")
        #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .overlayContainer("multiple",
                              containerConfiguration: ContainerConfigurationForQueueTypeDemo(
                                  queueType: .multiple,
                                  maximumNumberOfViewsInMultipleMode: UInt(maxNumberOfView),
                                  delayForShowingNext: delayForNext
                              ))
            .overlayContainer("oneByOne",
                              containerConfiguration: ContainerConfigurationForQueueTypeDemo(
                                  queueType: .oneByOne,
                                  maximumNumberOfViewsInMultipleMode: UInt(maxNumberOfView),
                                  delayForShowingNext: delayForNext
                              ))
            .overlayContainer("oneByOneWaitFinish",
                              containerConfiguration: ContainerConfigurationForQueueTypeDemo(
                                  queueType: .oneByOneWaitFinish,
                                  maximumNumberOfViewsInMultipleMode: UInt(maxNumberOfView),
                                  delayForShowingNext: delayForNext
                              ))
    }

    func generateContainerView() -> some ContainerView {
        let height = CGFloat.random(in: 50...100)
        let text = LocalizedStringKey("MessageText \(messageID)")
        withAnimation {
            messageID += 1
        }
        let textColor = [Color.red, .blue, .green, .black].randomElement() ?? .brown
        let background = [Material.regular, .regularMaterial, .thinMaterial, .ultraThinMaterial].randomElement() ?? .thick
        return Message(height: height, background: background, text: text, textColor: textColor)
    }

    @ViewBuilder
    func adjustmentView() -> some View {
        switch queueType {
        case .oneByOne:
            EmptyView()
        case .oneByOneWaitFinish:
            sliderOfDelayForNext()
        case .multiple:
            VStack {
                sliderOfNumberOfViews()
                sliderOfDelayForNext()
            }
        }
    }

    @ViewBuilder
    func sliderOfNumberOfViews() -> some View {
        VStack {
            Text("SliderOfNumberOfViewLabel \(Int(maxNumberOfView))")
            Slider(value: $maxNumberOfView,
                   in: 3...10,
                   step: 1.0)
        }
        .padding(.horizontal, 30)
    }

    @ViewBuilder
    func sliderOfDelayForNext() -> some View {
        VStack {
            Text("SliderOfDelayForShowNext \(String(format:"%.1f",delayForNext))")
            Slider(value: $delayForNext, in: 0.0...3.0)
        }
        .padding(.horizontal, 30)
    }

    func reset() {
        messageID = 1
        manager.dismissAllView(in: containers, animated: true)
    }
}

extension ContainerViewQueueType:Information {
    var information: (name: String, description: LocalizedStringKey) {
        switch self {
        case .multiple:
            return ("multiple", "MultipleDescription")
        case .oneByOne:
            return ("oneByOne", "OneByOneDescription")
        case .oneByOneWaitFinish:
            return ("oneByOneWaitFinish", "OneByOneWaitFinishDescription")
        }
    }
}

extension ContainerViewQueueType: Identifiable {
    public var id: String {
        information.name
    }
}

extension ContainerViewQueueType: CaseIterable {
    public static var allCases: [ContainerViewQueueType] {
        [.multiple, .oneByOne, .oneByOneWaitFinish]
    }
}

struct QueueTypeDemoPreview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            QueueTypeDemo()
                .navigationTitle("Queue Type")
        }
    }
}

struct ContainerConfigurationForQueueTypeDemo: ContainerConfigurationProtocol {
    let queueType: ContainerViewQueueType
    let displayType: ContainerViewDisplayType = .vertical
    var spacing: CGFloat = 10
    let alignment: Alignment? = .bottom
    let insets: EdgeInsets = .init(top: 0, leading: 0, bottom: 20, trailing: 0)
    let maximumNumberOfViewsInMultipleMode: UInt
    let delayForShowingNext: TimeInterval
}
