//
//  MacView.swift
//  OverlayDemo
//
//  Created by Yang Xu on 2020/8/12.
//

import Foundation
import SwiftUI
import SwiftUIOverlayContainer

#if os(macOS)
struct DemoView:View{
    @EnvironmentObject var manager:OverlayContainerManager
    @State var more = false
    let width:CGFloat
    var body: some View{
        VStack{
            Text("Hello world").padding(.top,30)
            Button("close"){
                manager.closeOverlayView()
            }.foregroundColor(.blue)
            .padding(.bottom,30)
            Button("more"){
                more.toggle()
            }.foregroundColor(.blue)
            if more {
                Text("我是占位符.我是占位符.我是占位符.我是占位符.我是占位符.我是占位符.我是占位符.我是占位符.我是占位符.我是占位符.我是占位符.")
                    .lineLimit(10)
                    .frame(width:200,height: 150)
                    .padding(.bottom,30)
            }
            Spacer()
        }
        .foregroundColor(.white)
        .frame(minWidth:width,minHeight: 200)
        .background(
            Color.blue
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        
        .offset(y:10)
        
    }
}


struct DemoView1:View{
    @EnvironmentObject var manager:OverlayContainerManager
    var body: some View{
        
        VStack{
            Spacer()
            Text("disappear")
            Text(" after 5 sec")
                .padding(.bottom,30)
            Button("close"){
                manager.closeOverlayView()
            }
            Spacer()
        }
        .frame(width:200,height: 150)
        .background(BlurEffectView(material: .fullScreenUI))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}


struct DemoView2:View{
    let height:CGFloat
    @EnvironmentObject var manager:OverlayContainerManager
    var body: some View{
        
        VStack{
            Spacer()
            Text("Hello world").padding(.bottom,30)
            Button("close"){
                manager.closeOverlayView()
            }
            Spacer()
        }
        .frame(width:800,height:height)
        .background(BlurEffectView(material: .fullScreenUI))
        
        
    }
}



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

let style1 = OverlayContainerStyle(alignment: .center,
                                   coverColor: Color.black.opacity(0.3),
                                   shadow: .init (color: Color.black.opacity(0.3), radius: 20, x: 2, y: 0),
                                   blur: .popover,
                                   animation: .easeInOut ,
                                   transition:.opacity,
                                   animatable: true,
                                   autoHide: 5,
                                   enableDrag: false,
                                   clickDismiss: false)


let style2 = OverlayContainerStyle(alignment: .leading,
                                   coverColor: Color.gray.opacity(0.3),
                                   shadow:.init (color: Color.black.opacity(0.3), radius: 20, x: 2, y: 0),
                                   blur: nil,
                                   animation: .easeInOut ,
                                   transition:.move(edge:.leading),
                                   animatable: true,
                                   autoHide: nil,
                                   enableDrag: true,
                                   clickDismiss: true)

struct BlurEffectView: NSViewRepresentable
{
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode = .withinWindow
    
    func makeNSView(context: Context) -> NSVisualEffectView
    {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = NSVisualEffectView.State.active
        return visualEffectView
    }
    
    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context)
    {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}

#endif
