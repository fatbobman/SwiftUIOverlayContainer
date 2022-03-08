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
    /// Merge Alignment between container and container view.
    ///
    /// When the type of Container is **Stacking**, each Container View can specify its own alignment,
    /// and the priority is higher than the shadow style of Container.
    /// When Container type is **Horizontal** or **Vertical**, the shadow style of Container View will be ignored.
    ///
    /// Horizontal's default alignment is **leading**
    ///
    /// Vertical's default alignment is **bottom**
    ///
    /// Stacking's default alignment is **center**
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
