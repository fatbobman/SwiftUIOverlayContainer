//
//  GenericStack.swift
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

struct GenericStack<Content: View>: View {
    let alignment: Alignment
    let displayType: ContainerViewDisplayType
    let spacing: CGFloat
    let insets: EdgeInsets
    var content: () -> Content

    init(
        displayType: ContainerViewDisplayType,
        alignment: Alignment,
        spacing: CGFloat = 10,
        insets: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.displayType = displayType
        self.spacing = spacing
        self.insets = insets
        self.content = content
    }

    var body: some View {
        switch displayType {
        case .horizontal:
            HStack(spacing: spacing, content: content)
                .padding(insets)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: alignment)
        case .vertical:
            VStack(spacing: spacing, content: content)
                .padding(insets)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: alignment)
        case .stacking:
            ZStack(content: content)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        }
    }
}
