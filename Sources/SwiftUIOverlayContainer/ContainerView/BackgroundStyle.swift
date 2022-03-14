//
//  BackgroundStyle.swift
//
//
//  Created by Yang Xu on 2022/3/6
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation
import SwiftUI

/// The background Style for Container
public enum ContainerBackgroundStyle {
    case color(Color)
    case blur(BlurMaterial)
    case view(AnyView)
    case disable
}

extension ContainerBackgroundStyle {
    /// Provides a SwiftUI view base on background style
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .color(let color):
            color
        case .blur(let material):
            material.getBlurView()
        case .view(let view):
            view
        case .disable:
            Color.clear
        }
    }
}

public enum BlurMaterial {
    case regular
    case thick
    case thin
    case ultraThin
    case ultraThick
}

extension BlurMaterial {
    @ViewBuilder
    func getBlurView() -> some View {
        if #available(iOS 15, macOS 12, tvOS 15, *) {
            #if os(watchOS)
            Color.clear
            #else
            switch self {
            case .regular:
                Rectangle().fill(.regularMaterial)
            case .thick:
                Rectangle().fill(.thickMaterial)
            case .thin:
                Rectangle().fill(.thinMaterial)
            case .ultraThin:
                Rectangle().fill(.ultraThinMaterial)
            case .ultraThick:
                Rectangle().fill(.ultraThickMaterial)
            }
            #endif
        } else {
            Rectangle()
                .fill(.gray)
                .overlay(
                    VStack {
                        Text("Warning!")
                            .font(.title)
                            .foregroundColor(.red)
                            .padding(.bottom, 20)
                        Text(blueMessage)
                            .lineLimit(10)
                            .font(.body)
                            .padding(.horizontal, 30)
                    }
                )
        }
    }

    var blueMessage: String {
        """
        Blur backgrounds are only supported on iOS 15+ and macOS 12+. If you want to set a blur background, use the `.view(some blur view)`.

        You can find a blur solutions on the internet that support lower os versions, such as: https://github.com/twostraws/VisualEffects
        """
    }
}

extension ContainerBackgroundStyle {
    /// Provides the correct background style base on container configuration and container view configuration
    ///
    /// When the display type of container is stacking, each container view can specify its own background style, and that has higher priority than the background style of container configuration.
    /// When container display type is horizontal or vertical, the background style of container view will be ignored.
    ///
    ///     In stacking mode:
    ///
    ///     container         containerView          result
    ///       nil                nil                  Color.clear
    ///       nil                disable              Color.clear
    ///       nil                color                color
    ///       disable            disable              Color.clear
    ///       disable            nil                  Color.clear
    ///       color              blur                 blur
    ///       color(red)         color(blue)          color(blue)
    ///
    static func merge(
        containerBackgroundStyle: Self?,
        viewBackgroundStyle: Self?,
        containerViewDisplayType: ContainerViewDisplayType
    ) -> Self {
        switch containerViewDisplayType {
        case .horizontal, .vertical:
            return containerBackgroundStyle ?? .disable
        case .stacking:
            guard let containerBackgroundStyle = containerBackgroundStyle else { return viewBackgroundStyle ?? .disable }
            return viewBackgroundStyle ?? containerBackgroundStyle
        }
    }
}

/// Transition of container view's background
public enum ContainerBackgroundTransitionStyle {
    case identity
    case opacity

    var transition: AnyTransition {
        switch self {
        case .opacity:
            return .opacity
        case .identity:
            return .identity
        }
    }
}
