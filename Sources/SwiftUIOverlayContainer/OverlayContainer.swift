// 用于SwiftUI的通用Overlay View显示控件
// 项目代码结构模仿了 https://github.com/AndreaMiotto/PartialSheet/
// Created by Yang Xu on 2020/7/24.
//

import SwiftUI
import Combine

struct OverlayContainer: ViewModifier {
    @EnvironmentObject var manager:OverlayContainerManager
    let style:OverlayContainerStyle
    @State private var x:CGFloat = .zero
    @State private var y:CGFloat = .zero
    @State var timer = Timer.publish(every: 1, on: .main, in: .common)
    @State var cancellable:Set<AnyCancellable> = []
    let dismissWidth:CGFloat = 20
    func body(content:Content) -> some View{
        let drag = DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { value in
                let t = value.translation
                switch self.style.alignment{
                case .leading:
                    if t.width < 0 { self.x = t.width }
                case .trailing:
                    if t.width > 0 { self.x = t.width }
                case .top:
                    if t.height < 0 { self.y = t.height }
                case .bottom:
                    if t.height > 0 { self.y = t.height }
                default:
                    break
                }
                
            }.onEnded { value in
                let t = value.translation
                switch self.style.alignment{
                case .leading:
                    if t.width < -self.dismissWidth {
                        self.x = .zero
                        self.y = .zero
                        self.manager.closeOverlayView()
                    }
                    else {
                        self.x = .zero
                        self.y = .zero
                    }
                case .trailing:
                    if t.width > self.dismissWidth {
                        self.x = .zero
                        self.y = .zero
                        self.manager.closeOverlayView()
                    }
                    else {
                        self.x = .zero
                        self.y = .zero
                    }
                case .top:
                    if t.height < -self.dismissWidth {
                        self.x = .zero
                        self.y = .zero
                        self.manager.closeOverlayView()
                    }
                    else {
                        self.x = .zero
                        self.y = .zero
                    }
                    
                case .bottom:
                    if t.height > self.dismissWidth {
                        self.x = .zero
                        self.y = .zero
                        self.manager.closeOverlayView()
                    }
                    else {
                        self.x = .zero
                        self.y = .zero
                    }
                    
                default:
                    break
                }
                
            }
        
        return ZStack{
            Color.clear
                .zIndex(0.5)
            content
                .zIndex(1.0)
            
            ZStack(alignment:style.alignment){
                
                if style.coverColor != nil {
                    Rectangle()
                        .foregroundColor(style.coverColor!)
                        .transition(.opacity)
                        .opacity(manager.isPresented ? 1.0 : 0)
                        .onTapGesture{
                            if self.style.clickDismiss {
                                self.manager.closeOverlayView()
                            }
                        }.zIndex(1.5)
                }
                else {
                    Color.clear
                        .zIndex(1.5)
                }
                
                if style.blur != nil {
                    #if os(iOS)
                    BlurEffectView(style:style.blur!)
                        .transition(.opacity)
                        
                        .opacity(manager.isPresented ? 1.0 : 0)
                        .onTapGesture{
                            if self.style.clickDismiss {
                                self.manager.closeOverlayView()
                            }
                        }
                        .zIndex(1.8)
                    #endif
                    #if os(macOS)
                    BlurEffectView(material: .fullScreenUI)
                        .transition(.opacity)
                        .opacity(manager.isPresented ? 1.0 : 0)
                        .onTapGesture{
                            if style.clickDismiss {
                                manager.closeOverlayView()
                            }
                        }
                        .zIndex(1.8)
                    
                    #endif
                    
                }
                
                
                if manager.isPresented {
                    manager.content
                        .fixedSize()
                        .ifIs(style.shadow != nil){
                            $0.background(
                                ZStack{
                                    manager.content
                                        .shadow(radius: 0)
                                    Color.clear
                                }
                                .shadow(color: style.shadow!.color, radius: style.shadow!.radius, x: style.shadow!.x, y: style.shadow!.y)
                            )}
                        .ifIs(style.enableDrag){$0.gesture(drag)}
                        .offset(x:x,y:y)
                        .animation(style.animatable ? style.animation : .none)
                        .ifIs(style.transition != nil){
                            $0.transition(style.transition!)
                        }
                        .zIndex(3.0)
                        .onAppear{
                            if self.style.autoHide != nil {
                                self.timer = Timer.publish(every: self.style.autoHide!, on: .main, in: .common)
                                self.timer.connect().store(in: &self.cancellable)
                            }
                        }
                        .onDisappear{
                            self.cancellable.removeAll()
                        }
                        .onReceive(timer, perform: { _ in
                            self.manager.closeOverlayView()
                        })
                }
            }
            .zIndex(2.0)
            .animation(style.animatable ? style.animation : .none)
            .transition(.opacity)
            
            
        }
        .animation(.none)
        .edgesIgnoringSafeArea(.all)
    }
}

public extension View{
    func addOverlayContainer(style:OverlayContainerStyle = .defaultStyle()) -> some View{
        self.modifier(OverlayContainer(style: style ))
    }
}


// 下面的代码来自于 https://github.com/AndreaMiotto/PartialSheet/

internal enum DeviceType {
    case iphone
    case ipad
    case mac
}

#if os(iOS)
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
#endif

internal extension View {
    
    @ViewBuilder func ifIs<T>(_ condition: Bool, transform: (Self) -> T) -> some View where T: View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    #if os(iOS)
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
    #endif
}
