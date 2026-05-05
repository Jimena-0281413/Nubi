import SwiftUI

struct SplashLogoView: View {
    let duration: Double
    let onFinish: (() -> Void)?

    init(duration: Double = 1.2, onFinish: (() -> Void)? = nil) {
        self.duration = duration
        self.onFinish = onFinish
    }

    private let backgroundColor = Color(red: 46/255, green: 138/255, blue: 154/255) // #2E8A9A approx
    private let parchmentColor = Color(red: 240/255, green: 236/255, blue: 222/255)   // parchment-like off-white

    var body: some View {
        GeometryReader { geo in
            backgroundColor
                .ignoresSafeArea()
            VStack {
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(parchmentColor)
                        .frame(maxWidth: min(geo.size.width * 0.6, 300),
                               maxHeight: min(geo.size.width * 0.6, 300))
                        .shadow(radius: 6)
                    Image("LogoNUBIOFC")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: min(geo.size.width * 0.6, 300))
                }
                Spacer()
                // Text("Loading...").foregroundColor(.white).font(.footnote).padding(.bottom, 20)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                onFinish?()
            }
        }
    }
}

struct SplashLogoView_Previews: PreviewProvider {
    static var previews: some View {
        SplashLogoView()
            .previewDevice("iPhone 14")
    }
}
