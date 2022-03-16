//
//  BlockView.swift
//  Demo
//
//  Created by Yang Xu on 2022/3/16
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import SwiftUI

struct BlockView: View {
    let backgroundColor: Color = [.red, .orange, .pink, .blue, .green, .brown].randomElement() ?? .yellow
    let size: CGSize
    let text: LocalizedStringKey
    let opacity: Double
    @Environment(\.overlayContainer) var container
    var body: some View {
        Group {
            RoundedRectangle(cornerRadius: 15)
                .fill(backgroundColor.opacity(opacity))
                .frame(width: size.width, height: size.height)
                .overlay(
                    Text(text)
                        .font(.callout)
                )
        }.onTapGesture {
            container.dismiss()
        }
    }
}

struct BlockView_Previews: PreviewProvider {
    static var previews: some View {
        BlockView(size: .init(width: 70, height: 70), text: "Hello", opacity: 0.5)
            .previewLayout(.sizeThatFits)
    }
}
