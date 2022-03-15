//
//  TestView.swift
//  Demo (iOS)
//
//  Created by Yang Xu on 2022/3/15
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation
import SwiftUI
import SwiftUIOverlayContainer
import UIKit

struct TestView: View {
    @State var containerConfiguration = MutableContainerConfiguration()
    @Environment(\.overlayContainerManager) var overlayManager
    var body: some View {
        VStack {
            Button("show") {
                overlayManager.show(containerView: MessageView(), in: "testViewContainer")
//                overlayManager.show(view: MessageView(), in: "testViewContainer", using: MessageView())
            }
            Button("changeQueueType") {
                withAnimation(.default) {
                    containerConfiguration.delayForShowingNext = 3
                    containerConfiguration.alignment = .top
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .overlayContainer("testViewContainer", containerConfiguration: containerConfiguration)
        .onAppear {
            overlayManager.debugLevel = 3
        }
    }
}

struct MutableContainerConfiguration: ContainerConfigurationProtocol {
    var displayType: ContainerViewDisplayType = .vertical
    var queueType: ContainerViewQueueType = .oneByOneWaitFinish
    var alignment: Alignment? = .bottom
    var transition: AnyTransition? = .opacity
    var animation: Animation? = .default
    var delayForShowingNext = 0.5
}

struct MessageView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.orange.opacity(0.6))
            .frame(height: 50)
            .padding(.horizontal, 30)
            .overlay(
                Text("Message")
            )
    }
}

extension MessageView: ContainerViewConfigurationProtocol {
    var dismissGesture: ContainerViewDismissGesture? { .tap }
    var transition: AnyTransition? { .slide }
}
