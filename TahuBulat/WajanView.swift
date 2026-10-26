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
            // Wajan Outer Ring
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "0x2C3E50"), Color(hex: "0x1A252F")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 270, height: 270)
                .shadow(color: .black.opacity(0.6), radius: 20, y: 12)
            
            // Wajan Inner Rim
            Circle()
                .stroke(Color.gray.opacity(0.4), lineWidth: 4)
                .frame(width: 260, height: 260)
            
            // Minyak Panas (Hot Oil Layer)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "0xF39C12"), Color(hex: "0xD35400")],
                        center: .center,
                        startRadius: 20,
                        endRadius: 130
                    )
                )
                .frame(width: 240, height: 240)
            
            // Gelembung Minyak Mendidih (Frying Bubbles)
            ForEach(bubbles) { bubble in
                Circle()
                    .fill(Color.white.opacity(bubble.opacity))
                    .frame(width: bubble.size, height: bubble.size)
                    .position(x: bubble.x, y: bubble.y)
            }
            
            // Tahu Bulat Crispy (The Main Tofu Tap Target)
            ZStack {
                // Tahu Body Golden Brown
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "0xFAD7A0"), Color(hex: "0xD68910"), Color(hex: "0x7E5109")],
                            center: UnitPoint(x: 0.35, y: 0.35),
                            startRadius: 15,
                            endRadius: 90
                        )
                    )
                    .frame(width: 170, height: 170)
                    .shadow(color: Color(hex: "0x563805").opacity(0.8), radius: 15, y: 8)
                
                // Texture Cracks (Tekstur Tahu Kopong Gurih)
                VStack(spacing: 6) {
                    HStack(spacing: 8) {
                        Circle().fill(Color(hex: "0x6E2C00").opacity(0.3)).frame(width: 14, height: 14)
                        Circle().fill(Color(hex: "0x6E2C00").opacity(0.2)).frame(width: 10, height: 10)
                    }
                    Text("TAHU BULAT")
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(hex: "0x4A235A"))
                        .shadow(color: .white.opacity(0.3), radius: 1, y: 1)
                    
                    Text("Digoreng Dadakan")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color(hex: "0x5B2C6F"))
                }
            }
            .scaleEffect(tahuScale)
            .rotationEffect(.degrees(tahuRotation))
        }
        .onAppear {
            startBubbleSimulation()
        }
    }
    
    func triggerTapAnimation() {
        withAnimation(.spring(response: 0.12, dampingFraction: 0.35)) {
            tahuScale = 0.88
            tahuRotation = Double.random(in: -4...4)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.45)) {
                tahuScale = 1.0
                tahuRotation = 0.0
            }
        }
    }
    
    private func startBubbleSimulation() {
        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
            if bubbles.count < 14 {
                let angle = Double.random(in: 0...(2 * .pi))
                let distance = CGFloat.random(in: 30...100)
                let x = 135 + cos(angle) * distance
                let y = 135 + sin(angle) * distance
                let bubble = Bubble(x: x, y: y, size: CGFloat.random(in: 5...12), opacity: Double.random(in: 0.3...0.7))
                bubbles.append(bubble)
                
                let id = bubble.id
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    bubbles.removeAll { $0.id == id }
                }
            }
        }
    }
}
