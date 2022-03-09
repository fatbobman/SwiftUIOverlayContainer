//
//  ContainerManager.swift
//  SwiftUIOverlayContainer
//
//  Created by Yang Xu on 2022/3/9
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation
import SwiftUI

struct ContainerManagerKey: EnvironmentKey {
    static var defaultValue = ContainerManager.shared
}

public extension EnvironmentValues {
    var containerManager: ContainerManager { self[ContainerManagerKey.self] }
}
