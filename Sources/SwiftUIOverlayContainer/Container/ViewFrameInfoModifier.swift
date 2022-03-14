//
//  ViewFrameInfoModifier.swift
//  SwiftUIOverlayContainer
//
//  Created by Yang Xu on 2022/3/12
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation
import SwiftUI

struct ViewFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}

/// A view modifier to get frame information of attache view
struct GetFrameInfoModifier: ViewModifier {
    @Binding var bindingValue: CGRect
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ViewFrameKey.self, value: proxy.frame(in: .global))
                        .onPreferenceChange(ViewFrameKey.self, perform: { frame in
                            self.bindingValue = frame
                        })
                }
            )
    }
}

extension View {
    /// get the current view frame information to binding value
    func recordCurrentViewFrameInfo(to bindingValue: Binding<CGRect>) -> some View {
        modifier(GetFrameInfoModifier(bindingValue: bindingValue))
    }
}



extension OverlayContainer {
    /// Composite container environment value
    func compositeContainerEnvironmentValue(
        containerName: String,
        containerConfiguration: ContainerConfigurationProtocol,
        containerFrame: CGRect,
        dismissAction: @escaping () -> Void
    ) -> ContainerEnvironment {
        ContainerEnvironment(
            containerName: containerName,
            containerFrame: containerFrame,
            containerViewDisplayType: containerConfiguration.displayType,
            containerViewQueueType: containerConfiguration.queueType,
            dismiss: dismissAction
        )
    }
}
