//
//  MessageView.swift
//  Demo (iOS)
//
//  Created by Yang Xu on 2022/3/16
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import SwiftUI
import SwiftUIOverlayContainer

struct Message<S: ShapeStyle>: View {
    init(height: CGFloat, background: S, text: LocalizedStringKey, textColor: Color) {
        self.height = height
        self.background = background
        self.text = text
        self.textColor = textColor
    }

    let height: CGFloat
    let background: S
    let text: LocalizedStringKey
    let textColor: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(.regularMaterial)
            .frame(maxWidth: 400)
            .frame(height:height)
            .padding(.horizontal, 20)
            .overlay(
                Text(text)
                    .foregroundColor(textColor)
            )
    }
}

extension Message:ContainerViewConfigurationProtocol {
    var transition: AnyTransition? {
        .move(edge: .bottom).combined(with: .opacity)
    }

    var dismissGesture: ContainerViewDismissGesture? {
        .tap
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        Message(height: 50, background: .regularMaterial, text: "Hello world", textColor: .blue)
            .previewLayout(.sizeThatFits)
    }
}
