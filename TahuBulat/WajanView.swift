import SwiftUI

struct Bubble: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
}

struct WajanView: View {
    @ObservedObject var engine: GameEngine
    @State private var tahuScale: CGFloat = 1.0
    @State private var tahuRotation: Double = 0.0
    @State private var bubbles: [Bubble] = []
    
    var body: some View {
        ZStack {
            // Shadow under Wajan
            Circle()
                .fill(Color.black.opacity(0.35))
                .frame(width: 250, height: 250)
                .offset(y: 12)
                .blur(radius: 8)
            
            // Wajan Sprite / Outer Rim
            ZStack {
                SpriteView(name: "wajan_besar", contentMode: .fit)
                    .frame(width: 260, height: 260)
                
                // Hot Golden Frying Oil Layer
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "0xF5B041"),
                                Color(hex: "0xEB984E"),
                                Color(hex: "0xD35400")
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 105
                        )
                    )
                    .frame(width: 195, height: 195)
                    .opacity(0.88)
                
                // Sizzling Oil Bubbles
                ZStack {
                    ForEach(bubbles) { bubble in
                        Circle()
                            .fill(Color.white.opacity(bubble.opacity))
                            .frame(width: bubble.size, height: bubble.size)
                            .position(x: bubble.x, y: bubble.y)
                    }
                }
                .frame(width: 195, height: 195)
                .clipped()
                
                // Fried Crispy Tahu Bulat in Oil
                HStack(spacing: 12) {
                    ForEach(0..<3) { i in
                        SpriteView(name: "tahu_matang", contentMode: .fit)
                            .frame(width: 58, height: 58)
                            .shadow(color: Color(hex: "0x6E2C00").opacity(0.4), radius: 4, y: 3)
                            .offset(y: (i == 1) ? -10 : 8)
                    }
                }
                
                // Center Tap Target Highlight Banner
                VStack(spacing: 2) {
                    Text("GORENG!")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(hex: "0xC0392B").opacity(0.85))
                        .clipShape(Capsule())
                        .shadow(radius: 2)
                }
                .offset(y: 42)
            }
            .scaleEffect(tahuScale)
            .rotationEffect(.degrees(tahuRotation))
        }
        .onAppear {
            startBubbleSimulation()
        }
    }
    
    func triggerTapAnimation() {
        withAnimation(.spring(response: 0.1, dampingFraction: 0.3)) {
            tahuScale = 0.90
            tahuRotation = Double.random(in: -3...3)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                tahuScale = 1.05
                tahuRotation = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeOut(duration: 0.1)) {
                    tahuScale = 1.0
                }
            }
        }
    }
    
    private func startBubbleSimulation() {
        Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { _ in
            if bubbles.count < 16 {
                let angle = Double.random(in: 0...(2 * .pi))
                let distance = CGFloat.random(in: 15...80)
                let x = 97 + cos(angle) * distance
                let y = 97 + sin(angle) * distance
                let bubble = Bubble(x: x, y: y, size: CGFloat.random(in: 4...11), opacity: Double.random(in: 0.4...0.8))
                bubbles.append(bubble)
                
                let id = bubble.id
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    bubbles.removeAll { $0.id == id }
                }
            }
        }
    }
}
