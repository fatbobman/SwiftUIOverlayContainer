import Combine
import SwiftUI


public class OverlayContainerManager: ObservableObject {

    /// Published var to present or hide the partial sheet
    @Published var isPresented: Bool = false
    {
        didSet {
            if !isPresented {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                    self?.content = AnyView(EmptyView())
                    self?.onDismiss = nil
                }
            }
        }
    }
    
    /// The content of the sheet
    private(set) var content: AnyView
    /// the onDismiss code runned when the partial sheet is closed
    private(set) var onDismiss: (() -> Void)?

    public init() {
        self.content = AnyView(EmptyView())
    }
    
    public func setContent<T:View>(_ content:@escaping () -> T) {
        self.content = AnyView(content())
    }
    
    public func showOverlayView<T>(_ onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> T) where T: View {
        self.content = AnyView(content())
        self.onDismiss = onDismiss
        self.isPresented = true
    }

    /// Close the Partial Sheet and run the onDismiss function if it has been previously specified
    public func closeOverlayView() {
        self.isPresented = false
        self.onDismiss?()
    }
}

public struct OverlayContainerStyle{
    
    public struct Shadow{
        let color: Color
        let radius:CGFloat
        let x:CGFloat
        let y:CGFloat
        
        init(color:Color = Color(.sRGBLinear, white: 0, opacity: 0.33),radius:CGFloat = 10,x:CGFloat = 4,y:CGFloat = 0 ){
            self.color = color
            self.radius = radius
            self.x = x
            self.y = y
        }
    }
    
    let alignment:Alignment
    let coverColor:Color?
    let blur:UIBlurEffect.Style?
    let shadow:Shadow?
    let animation:Animation
    let transition:AnyTransition
    let animatable:Bool
    let autoHide:Double?
    let enableDrag:Bool
    
    init(alignment:Alignment = .center,coverColor:Color? = Color.black.opacity(0.4),shadow:Shadow? = nil,blur:UIBlurEffect.Style? = UIBlurEffect.Style.systemChromeMaterial, animation:Animation = .easeInOut, transition:AnyTransition = .opacity,animatable:Bool = true,autoHide:Double? = nil,enableDrag:Bool = false){
        self.alignment = alignment
        self.animation = animation
        self.transition = transition
        self.animatable = animatable
        self.coverColor = coverColor
        self.blur = blur
        self.shadow = shadow
        self.autoHide = autoHide
        self.enableDrag = enableDrag
    }

    
    public static func defaultStyle() -> OverlayContainerStyle{
        OverlayContainerStyle(alignment: .center, animation: .easeInOut,transition: .opacity,animatable: true )
    }
}

internal struct BlurEffectView: UIViewRepresentable {

    /// The style of the Blut Effect View
    var style: UIBlurEffect.Style = .systemMaterial

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
