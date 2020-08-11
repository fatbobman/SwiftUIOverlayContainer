# SwiftUIOverlayContainer

这是在全窗口下,显示各种弹出式View的SwiftUI库.目前支持 iOS 和 macOS

A  SwiftUI modifier to present overlay View on custom style

代码思路收到了[PartialSheet](https://github.com/AndreaMiotto/PartialSheet)很大的影响

## Features

##  How to Use

1. Add a **OverlayContainerManager** instance as an *environment object* to your Root View in you *SceneDelegate* or App
```Swift
@main
struct Test: App {
    let manager = OverlayContainerManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(manager)
        }
    }
}
```
2. Add the **Partial View** to your *Root View*, and if you want give it a style. In your RootView file at the end of the builder add the following modifier:

```Swift
struct ContentView: View {

    var body: some View {
       ...
       .addOverlayContainer(style: <OverlayContainerStyle>)
    }
}
```

3. In anyone of your views add a reference to the *environment object* and than just call the `showOverlayView<T>(_ onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> T) where T: View` func whenever you want like this:

```Swift
@EnvironmentObject var manager: OverlayContainerManager

...

Button(action: {
    self.manager.showOverlayView({
        print("dismissed")
    }) {
         VStack{
            Text("This is Overlay View")
         }
    }
}, label: {
    Text("Show overlyView")
})
```
**样式说明**
```swift
let style2 = OverlayContainerStyle(
                                   alignment: .leading,  //容器对齐位置
                                   coverColor: Color.gray.opacity(0.3), //覆盖色
                                   shadow:.init (color: Color.black.opacity(0.3), radius: 20, x: 2, y: 0), //阴影样式
                                   blur: nil,  //模糊样式
                                   animation: .easeInOut ,  //动画曲线
                                   transition:.move(edge:.leading),  //进出动画效果
                                   animatable: true,  //是否显示动画
                                   autoHide: nil,  //是否自动隐藏,可设置秒数
                                   enableDrag: true,  //是否允许滑动取消,目前只支持 .leading,.trailing,.bottom,.top
                                   clickDismiss: true) //是否支持显示后,点击屏幕其他位置取消

```

更多具体应用,请参看 DEMO


