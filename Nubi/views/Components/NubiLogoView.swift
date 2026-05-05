import SwiftUI

/// A view that displays the "LogoNUBIOFC" asset proportionally.
/// 
/// Usage examples:
/// ```swift
/// LogoNUBIOFCView() // Defaults to maxWidth 200
/// LogoNUBIOFCView(maxWidth: 150)
/// LogoNUBIOFCView(height: 100)
/// LogoNUBIOFCView(maxWidth: 150, height: 100)
/// ```
struct LogoNUBIOFCView: View {
    var maxWidth: CGFloat? = nil
    var height: CGFloat? = nil
    
    var body: some View {
        Image("LogoNUBIOFC")
            .resizable()
            .scaledToFit()
            .frame(
                maxWidth: maxWidth ?? (height == nil ? 200 : nil),
                height: height
            )
    }
}

#if DEBUG
struct LogoNUBIOFCView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("Default (maxWidth 200)")
            LogoNUBIOFCView()
                .border(Color.gray)
            
            Text("Constrained maxWidth 150")
            LogoNUBIOFCView(maxWidth: 150)
                .border(Color.gray)
            
            Text("Constrained height 100")
            LogoNUBIOFCView(height: 100)
                .border(Color.gray)
            
            Text("Constrained maxWidth 150 & height 100")
            LogoNUBIOFCView(maxWidth: 150, height: 100)
                .border(Color.gray)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
