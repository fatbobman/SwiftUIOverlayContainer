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
                    NavigationLink(demo.label, destination: demo.view)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("MenuNavigationTitle")
            VStack {
                Text("MenuTip")
            }
        }
    }

    let demos: [DemoLink] = [
        .init("QueueTypeLinkLabel", QueueTypeDemo()),
        .init("DisplayTypeLinkLabel", DisplayTypeDemo()),
        .init("ViewConfigurationLabel", ViewConfigurationDemo()),
        .init("Gesture", EmptyView()),
        .init("Transition", EmptyView()),
        .init("Background", EmptyView()),
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
