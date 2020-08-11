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
    @State var overlayStyle:OverlayContainerStyle = style
    var body: some View {
        GeometryReader{ proxy in
            ZStack{
                Color.clear
                VStack{
                    MyButton(text: "Demo1")
                        .contentShape(Rectangle())
                        .onTapGesture {
                            overlayStyle = style
                            manager.showOverlayView{DemoView(width: proxy.size.width * 0.8)}
                        }
                    
                    MyButton(text: "Demo2")
                        .contentShape(Rectangle())
                        .onTapGesture {
                            overlayStyle = style1
                            manager.showOverlayView{DemoView1()}
                        }
                    
                    MyButton(text: "Demo3")
                        .contentShape(Rectangle())
                        .onTapGesture {
                            overlayStyle = style2
                            manager.showOverlayView{DemoView2(height: proxy.frame(in: .local).height)}
                        }
                }
                
            }
            .addOverlayContainer(style: overlayStyle)
        }
        .edgesIgnoringSafeArea(.all)
        
    }
}

struct MyButton:View{
    var text:String
    @EnvironmentObject var manager:OverlayContainerManager
    var body: some View{
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.blue.opacity(0.7))
            .frame(width:120,height:80)
            .overlay(
                Text(text)
                    .lineLimit(10)
                    .foregroundColor(.white)
                
            )
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
                                  shadow:
                                  .init(color: Color.black.opacity(0.3), radius: 20, x: 2, y: -2),
                                  blur: .light,
                                  animation: .easeInOut ,
                                  transition:transition,
                                  animatable: true,
                                  autoHide: nil,
                                  enableDrag: true,
                                  clickDismiss: true)


let style1 = OverlayContainerStyle(alignment: .center,
                                   coverColor: Color.black.opacity(0.3),
                                   shadow: nil,
                                   blur: .regular,
                                   animation: .easeInOut ,
                                   transition:.asymmetric(insertion: .slide, removal: AnyTransition.move(edge: .top).combined(with: .opacity)),
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

let style1 = OverlayContainerStyle(alignment: .center,
                                   coverColor: Color.black.opacity(0.3),
                                   shadow: nil,
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
                                   enableDrag: false,
                                   clickDismiss: false)
#endif

let transition:AnyTransition = .asymmetric(insertion: AnyTransition.move(edge: .bottom).combined(with: .opacity).animation(.easeIn(duration: 0.5)),
                                           removal: AnyTransition.move(edge: .bottom).combined(with: .opacity).animation(.easeIn(duration: 0.3))
)

struct DemoView:View{
    @EnvironmentObject var manager:OverlayContainerManager
    @State var more = false
    let width:CGFloat
    var body: some View{
        VStack{
            Text("Hello world").padding(.top,30)
            Button("close"){
                manager.closeOverlayView()
            }
            .padding(.bottom,30)
            Button("more"){
                more.toggle()
            }
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
        .background(BlurEffectView(style: .regular))
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
        .frame(width:300,height:height)
        .background(BlurEffectView(style: .regular))
        
        
    }
}


struct BlurEffectView: UIViewRepresentable {
    
    /// The style of the Blut Effect View
    var style: UIBlurEffect.Style = .systemMaterial
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
