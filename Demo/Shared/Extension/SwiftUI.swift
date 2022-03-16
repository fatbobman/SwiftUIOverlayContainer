//
//  SwiftUI.swift
//  Demo
//
//  Created by Yang Xu on 2022/3/16
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman 
//  My Blog: https://www.fatbobman.com
//


import Foundation
import SwiftUI

extension View{
    func eraseToAnyView() -> AnyView{
        AnyView(self)
    }
}

#if canImport(UIKit)
import UIKit
let grayColor = UIColor.systemGroupedBackground
#endif

#if canImport(AppKit)
let grayColor = NSColor.windowBackgroundColor
#endif
