//
//  ContentView.swift
//  Shared
//
//  Created by Yang Xu on 2020/8/11.
//

import SwiftUI
import SwiftUIOverlayContainer
struct ContentView: View {
    @EnvironmentObject var manager:OverlayContainerManager
    var body: some View {
        ZStack{
            Color.clear
            Image("background")
            VStack{
                Text("Hello, world!")
                    .padding()
                Button("open"){
                    manager.showOverlayView{
                        DemoView1()
                    }
                }
            }
            .onAppear{
                manager.showOverlayView{DemoView1()}
            }
        }.addOverlayContainer(style: style)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#if os(iOS)
let style = OverlayContainerStyle(alignment: .bottom,
                                  coverColor: nil,
                                  shadow: .init(color: Color.black.opacity(0.5), radius: 20, x: 2, y: -2),
                                  blur: .systemChromeMaterialDark,
                                  animation: .easeInOut ,
                                  transition:transition,
                                  animatable: true,
                                  autoHide: nil,
                                  enableDrag: true,
                                  clickDismiss: true)
#endif

#if os(macOS)
let style = OverlayContainerStyle(alignment: .bottom,
                                  coverColor: Color.black.opacity(0.3),
                                  shadow: nil,
                                  blur: .windowBackground,
                                  animation: .easeInOut ,
                                  transition:.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)),
                                  animatable: true,
                                  autoHide: nil,
                                  enableDrag: true,
                                  clickDismiss: true)
#endif

let transition:AnyTransition = .asymmetric(insertion: AnyTransition.move(edge: .bottom).combined(with: .opacity).animation(.easeIn(duration: 0.5)),
                                           removal: AnyTransition.move(edge: .bottom).combined(with: .opacity).animation(.easeIn(duration: 0.3))
)

struct DemoView1:View{
    @EnvironmentObject var manager:OverlayContainerManager
    
    
    var body: some View{
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.orange)
            .frame(idealWidth:400,idealHeight: 200)
            .overlay(
                VStack{
                    Spacer()
                    Text("Hello world").padding(.bottom,30)
                    Button("close"){
                        manager.closeOverlayView()
                    }
                    Spacer()
                }
            )
            .offset(y:30)
    }
}


