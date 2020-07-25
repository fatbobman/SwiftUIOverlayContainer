# SwiftUIOverlayContainer

A description of this package.

A  SwiftUI modifier to present overlay View on custom style

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
