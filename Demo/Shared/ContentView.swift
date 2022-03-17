//
//  ContentView.swift
//  Shared
//
//  Created by Yang Xu on 2022/3/15
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                ForEach(demos) { demo in
                    NavigationLink(demo.label, destination: demo.view.toolbarForMac)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("MenuNavigationTitle")
            VStack {
                Text("MenuTip")
            }
            .toolbarForMac()
        }
    }

    let demos: [DemoLink] = [
        .init("QueueTypeLinkLabel", QueueTypeDemo()),
        .init("DisplayTypeLinkLabel", DisplayTypeDemo()),
        .init("ViewConfigurationLabel", ViewConfigurationDemo()),
        .init("DismissGestureLabel", DismissGestureDemo()),
        .init("ViewBackgroundLalel", EmptyView()),
        .init("Bind", EmptyView())
    ]
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct DemoLink: Identifiable {
    let id = UUID()
    let label: LocalizedStringKey
    let view: AnyView

    init<V: View>(_ label: LocalizedStringKey, _ view: V) {
        self.label = label
        self.view = view.eraseToAnyView()
    }
}

extension View {
    private func toggleSidebar() { // 2
        #if os(iOS)
        #else
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }

    @ViewBuilder
    func toolbarForMac() -> some View {
        #if os(macOS) && !targetEnvironment(macCatalyst)
        self.toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: { // 1
                    Image(systemName: "sidebar.leading")
                })
            }
        }
        #else
        self
        #endif
    }
}
