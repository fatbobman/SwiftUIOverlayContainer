//
//  Protocol.swift
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

protocol Information {
    var information: (name: String, description: LocalizedStringKey) { get }
}
