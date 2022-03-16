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
        NavigationView{
            List {
                NavigationLink("Queue Type", destination: QueueTypeDemo())
            }
            .listStyle(.sidebar)
            .navigationTitle("Demo")
            VStack{
                Text("Select Demo")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
