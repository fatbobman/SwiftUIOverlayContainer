//
//  OverlayDemoApp.swift
//  Shared
//
//  Created by Yang Xu on 2020/8/11.
//

import SwiftUI
import SwiftUIOverlayContainer

@main
struct OverlayDemoApp: App {
    let overlayManager = OverlayContainerManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(overlayManager)
        }
    }
}
