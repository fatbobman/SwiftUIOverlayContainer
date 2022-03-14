//
//  File.swift
//
//
//  Created by Yang Xu on 2022/3/7
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation
import SwiftUI

extension Alignment {
    /// Provides the correct alignment based on the container view display type.
    ///
    /// When the display type of container is **Stacking**, each container view can specify its own alignment in container view configuration, which has higher priority than the alignment setting in container configuration.
    ///
    /// When the container display type is **Horizontal** or **Vertical**, the container view's alignment setting will be ignored.
    ///
    /// The default alignment for **Horizontal mode** is **leading**, If both view configuration and container configuration are nil. The behavior of container is to pop view from leading side.
    ///
    /// The default alignment for **Vertical mode** is **bottom**, If both view configuration and container configuration are nil. The behavior of container is to pop view from bottom side.
    ///
    /// The default alignment for **Stacking mode**  is **center**, if both view configuration and container configuration are nil. The behavior of container is to show view from center of screen.
    ///
    static func merge(containerAlignment: Self?, viewAlignment: Self?, containerViewDisplayType: ContainerViewDisplayType) -> Alignment {
        switch containerViewDisplayType {
        case .horizontal:
            return containerAlignment ?? .leading
        case .vertical:
            return containerAlignment ?? .bottom
        case .stacking:
            guard let containerAlignment = containerAlignment else { return viewAlignment ?? .center }
            return viewAlignment ?? containerAlignment
        }
    }
}
