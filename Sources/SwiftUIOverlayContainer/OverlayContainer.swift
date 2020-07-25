//
//  OverlayView.swift
//  beta3Test
//
//  Created by Yang Xu on 2020/7/24.
//

import SwiftUI
import Combine

struct OverlayContainer: ViewModifier {
    @EnvironmentObject var manager:OverlayContainerManager
    let style:OverlayContainerStyle
    @State private var x:CGFloat = .zero
    @State private var y:CGFloat = .zero
    
    func body(content:Content) -> some View{
        let distance:CGFloat = 50
        let drag = DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { value in
                let t = value.translation
                switch style.alignment{
                case .leading:
                    if t.width < -distance {manager.closeOverlayView()}
                    if t.width < 0 { x = t.width }
                case .trailing:
                    if t.width > distance {manager.closeOverlayView()}
                    if t.width > 0 { x = t.width }
                case .top:
                    if t.height < -distance {manager.closeOverlayView()}
                    if t.height < 0 { y = t.height }
                case .bottom:
                    if t.height > distance {manager.closeOverlayView()}
                    if t.height > 0 { y = t.height }
                default:
                    break
                }
                
            }.onEnded { value in
                x = .zero
                y = .zero
            }
        
       return ZStack{
            
            content
                .zIndex(1.0)
            
            
            ZStack(alignment:style.alignment){
                
                if manager.isPresented {
                    
                    if style.coverColor != nil {
                        Rectangle()
                            .foregroundColor(style.coverColor!)
                    }
                    else {
                        Color.clear
                    }
                    
                    if style.blur != nil {
                        BlurEffectView(style:style.blur!)
                    }
                    
                }

                if manager.isPresented {
                    manager.content
                        .fixedSize()
//                        .background(
//                            Color.clear
                        .ifIs(style.shadow != nil){
                            $0
                                .shadow(color: style.shadow!.color, radius: style.shadow!.radius, x: style.shadow!.x, y: style.shadow!.y)
                        }
//                                )
                        .offset(x:x,y:y)
                        .ifIs(style.enableDrag){$0.gesture(drag)}
                        .animation(style.animatable ? style.animation : nil)
                        .transition(style.transition)
                        .zIndex(3.0)
                        .onAppear{
                            if style.autoHide != nil {
                            DispatchQueue.main.asyncAfter(deadline: .now() + style.autoHide!){
                                if manager.isPresented {
                                    manager.closeOverlayView()
                                }
                            }
                            }
                        }
                }
            }
            .animation(.easeInOut)
            .transition(.opacity)
            .zIndex(2.0)
            
        }
        .edgesIgnoringSafeArea(.all)
    }
}

public extension View{
    func addOverlayContainer(style:OverlayContainerStyle = .defaultStyle()) -> some View{
        self.modifier(OverlayContainer(style: style ))
    }
}


internal enum DeviceType {
    case iphone
    case ipad
    case mac
}

internal var deviceType: DeviceType = {
    #if targetEnvironment(macCatalyst)
    return .mac
    #else
    if UIDevice.current.userInterfaceIdiom == .pad {
        return .ipad
    } else {
        return .iphone
    }
    #endif
}()

internal extension View {

    @ViewBuilder func ifIs<T>(_ condition: Bool, transform: (Self) -> T) -> some View where T: View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder func iPhone<T>(_ transform: (Self) -> T) -> some View where T: View {
        if deviceType == .iphone {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder func iPad<T>(_ transform: (Self) -> T) -> some View where T: View {
        if deviceType == .ipad {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder func mac<T>(_ transform: (Self) -> T) -> some View where T: View {
        if deviceType == .mac {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder func iPadOrMac<T>(_ transform: (Self) -> T) -> some View where T: View {
        if deviceType == .mac || deviceType == .ipad {
            transform(self)
        } else {
            self
        }
    }
}
