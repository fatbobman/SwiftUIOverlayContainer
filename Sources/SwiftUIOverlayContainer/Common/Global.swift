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

import Combine
import Foundation

typealias DismissAction = () -> Void
typealias AppearAction = () -> Void
typealias DisappearAction = () -> Void
typealias ContainerViewPublisher = Publishers.Share<PassthroughSubject<IdentifiableContainerView, Never>>
typealias ContainerName = String
