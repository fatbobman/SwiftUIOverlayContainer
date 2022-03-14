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

/// A generic stack , that behaves differently depending on the display type of container
///
/// `horizontal` is based on HStack, and  set spacing, alignment and insets on it
///
/// `vertical` is based on VStack, and can set spacing, alignment and insets on it
///
/// `stacking` is based on ZStack, and will ignore spacing setting, alignment and insets will be set during the view composition phase and not here.
///
struct GenericStack<Content: View>: View {
    /// alignment for horizontal type and vertical type
    let alignment: Alignment
    /// the display type of container
    let displayType: ContainerViewDisplayType
    /// spacing  for horizontal type and vertical type
    let spacing: CGFloat
    /// insets for horizontal type and vertical type
    let insets: EdgeInsets
    /// A view builder that creates the content of this stack.
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
                // all stack types will use all available space
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

extension Array {
    /// Reorder all elements based on container display type and alignment
    func alignment(displayType: ContainerViewDisplayType, by alignment: Alignment) -> Self {
        switch displayType {
        case .horizontal:
            if [Alignment.leading, .topLeading, .bottomLeading].contains(alignment) {
                return self.lazy.reversed()
            } else {
                return self
            }
        case .vertical:
            if [Alignment.top, .topLeading, .topTrailing].contains(alignment) {
                return self.lazy.reversed()
            } else {
                return self
            }
        case .stacking:
            return self
        }
    }
}

#if DEBUG
struct GenericStackPreview: PreviewProvider {
    static let items = (0...5).map { $0 }
    static var previews: some View {
        Group {
            GenericStack(displayType: .stacking, alignment: .bottom) {
                ForEach(items.alignment(displayType: .stacking, by: .bottom), id: \.self) { i in
                    Text("layer \(i)")
                        .foregroundColor(.blue)
                        .offset(x: CGFloat(i) * 5, y: CGFloat(i) * 5)
                }
            }
            .border(.red)
            .previewLayout(.fixed(width: 200, height: 200))

            GenericStack(displayType: .vertical, alignment: .top) {
                ForEach(items.alignment(displayType: .vertical, by: .top), id: \.self) { i in
                    Text("\(i)")
                        .foregroundColor(.blue)
                }
            }
            .border(.red)
            .previewLayout(.fixed(width: 200, height: 200))

            GenericStack(displayType: .vertical, alignment: .bottom) {
                ForEach(items.alignment(displayType: .vertical, by: .bottom), id: \.self) { i in
                    Text("\(i)")
                        .foregroundColor(.blue)
                }
            }
            .border(.red)
            .previewLayout(.fixed(width: 200, height: 200))

            GenericStack(displayType: .horizontal, alignment: .leading) {
                ForEach(items.alignment(displayType: .horizontal, by: .leading), id: \.self) { i in
                    Text("\(i)")
                        .foregroundColor(.blue)
                }
            }
            .border(.red)
            .previewLayout(.fixed(width: 200, height: 200))

            GenericStack(
                displayType: .horizontal,
                alignment: .trailing, spacing: 3,
                insets: .init(top: 0, leading: 0, bottom: 0, trailing: 20)
            ) {
                ForEach(items.alignment(displayType: .horizontal, by: .trailing), id: \.self) { i in
                    Text("\(i)")
                        .foregroundColor(.blue)
                }
            }
            .border(.red)
            .previewLayout(.fixed(width: 200, height: 200))

            GenericStack(displayType: .horizontal, alignment: .topLeading) {
                ForEach(items.alignment(displayType: .horizontal, by: .topLeading), id: \.self) { i in
                    Text("\(i)")
                        .foregroundColor(.blue)
                }
            }
            .border(.red)
            .previewLayout(.fixed(width: 200, height: 200))
        }
    }
}
#endif
