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
    @State private var wajanScale: CGFloat = 1.0
    @State private var wajanRotation: Double = 0.0
    @State private var bubbles: [Bubble] = []
    
    var body: some View {
        ZStack {
            // Soft Realistic Drop Shadow under Wajan on Counter Table
            Ellipse()
                .fill(Color.black.opacity(0.45))
                .frame(width: 260, height: 140)
                .offset(y: 55)
                .blur(radius: 10)
            
            // Stove Base (Kompor Pemanas Wajan)
            SpriteView(name: "wajan_kompor", contentMode: .fit)
                .frame(width: 180, height: 50)
                .offset(y: 65)
                .opacity(0.85)
            
            // Giant Wok Container
            ZStack {
                // Wajan Sprite Metal Outer Rim with Wooden Handles
                SpriteView(name: "wajan_besar", contentMode: .fit)
                    .frame(width: 270, height: 270)
                
                // Hot Golden Sizzling Oil Layer (Elliptical to match wok perspective)
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "0xFFC048"),
                                Color(hex: "0xFFA801"),
                                Color(hex: "0xD35400"),
                                Color(hex: "0xA04000")
                            ],
                            center: .center,
                            startRadius: 15,
                            endRadius: 95
                        )
                    )
                    .frame(width: 195, height: 155)
                    .offset(y: 8)
                    .overlay(
                        Ellipse()
                            .stroke(Color(hex: "0xFFEAA7").opacity(0.4), lineWidth: 2)
                            .frame(width: 195, height: 155)
                            .offset(y: 8)
                    )
                
                // Sizzling Oil Bubbles inside Oil Bowl
                ZStack {
                    ForEach(bubbles) { bubble in
                        Circle()
                            .fill(Color.white.opacity(bubble.opacity))
                            .frame(width: bubble.size, height: bubble.size)
                            .position(x: bubble.x, y: bubble.y)
                    }
                }
                .frame(width: 190, height: 150)
                .offset(y: 8)
                .clipped()
                
                // Fried Crispy Golden Tahu Bulat in Oil (Populated & Dynamic)
                ZStack {
                    // Tahu 1 - Center Left
                    SpriteView(name: "tahu_matang", contentMode: .fit)
                        .frame(width: 52, height: 52)
                        .shadow(color: Color(hex: "0x6E2C00").opacity(0.45), radius: 4, y: 3)
                        .offset(x: -45, y: -6)
                    
                    // Tahu 2 - Center High
                    SpriteView(name: "tahu_matang", contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .shadow(color: Color(hex: "0x6E2C00").opacity(0.45), radius: 4, y: 3)
                        .offset(x: 10, y: -24)
                    
                    // Tahu 3 - Center Right
                    SpriteView(name: "tahu_matang", contentMode: .fit)
                        .frame(width: 54, height: 54)
                        .shadow(color: Color(hex: "0x6E2C00").opacity(0.45), radius: 4, y: 3)
                        .offset(x: 48, y: 4)
                    
                    // Tahu 4 - Bottom Center
                    SpriteView(name: "tahu_matang", contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .shadow(color: Color(hex: "0x6E2C00").opacity(0.45), radius: 4, y: 3)
                        .offset(x: -8, y: 22)
                }
                .offset(y: 4)
                
                // Tap Instruction Banner
                HStack(spacing: 5) {
                    Text("🔥")
                        .font(.system(size: 13))
                    Text("TAP GORENG!")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "0xE74C3C"), Color(hex: "0xC0392B")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.4), radius: 4, y: 2)
                .offset(y: 66)
            }
            .scaleEffect(wajanScale)
            .rotationEffect(.degrees(wajanRotation))
        }
        .onAppear {
            startBubbleSimulation()
        }
    }
    
    func triggerTapAnimation() {
        withAnimation(.spring(response: 0.1, dampingFraction: 0.35)) {
            wajanScale = 0.94
            wajanRotation = Double.random(in: -2...2)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.45)) {
                wajanScale = 1.04
                wajanRotation = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeOut(duration: 0.1)) {
                    wajanScale = 1.0
                }
            }
        }
    }
    
    private func startBubbleSimulation() {
        Timer.scheduledTimer(withTimeInterval: 0.14, repeats: true) { _ in
            if bubbles.count < 14 {
                let x = CGFloat.random(in: 25...165)
                let y = CGFloat.random(in: 20...130)
                let bubble = Bubble(
                    x: x,
                    y: y,
                    size: CGFloat.random(in: 4...10),
                    opacity: Double.random(in: 0.45...0.85)
                )
                bubbles.append(bubble)
                
                let id = bubble.id
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    bubbles.removeAll { $0.id == id }
                }
            }
        }
    }
}
