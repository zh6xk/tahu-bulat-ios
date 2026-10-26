import SwiftUI

struct MainGameView: View {
    @StateObject private var engine = GameEngine()
    @State private var showShop: Bool = false
    @State private var akangCooking: Bool = false
    
    var body: some View {
        ZStack {
            // Full Screen Background Layout
            VStack(spacing: 0) {
                // 1. Bandung Night Sky & Street Backdrop
                ZStack(alignment: .bottom) {
                    LinearGradient(
                        colors: [Color(hex: "0x0B192C"), Color(hex: "0x1E3E62")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    SpriteView(name: "bg_bandung", contentMode: .fill)
                        .opacity(0.92)
                }
                .frame(maxHeight: 330)
                .clipped()
                
                // 2. Asphalt Road with Dashed Centerline
                ZStack {
                    SpriteView(name: "bg_jalan", contentMode: .fill)
                }
                .frame(height: 38)
                .clipped()
                
                // 3. Kitchen Counter Table Surface (Rich Warm Mahogany Tone)
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(hex: "0x2C1609"),
                            Color(hex: "0x200F05"),
                            Color(hex: "0x140903")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    // Subtle Warm Tabletop Texture Line
                    VStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "0x8D6E63"), Color(hex: "0x4E342E")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 3)
                        Spacer()
                    }
                }
                .ignoresSafeArea()
            }
            .ignoresSafeArea()
            
            // Foreground Interactive UI & Elements
            VStack(spacing: 0) {
                // Top Header Stats Bar
                HStack(spacing: 12) {
                    // Coin Counter Bar with Golden Accent
                    HStack(spacing: 8) {
                        SpriteView(name: "koin_emas", contentMode: .fit)
                            .frame(width: 32, height: 32)
                        
                        Text(engine.formatNumber(engine.coins))
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundStyle(Color(hex: "0x78281F"))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "0xFEF9E7"), Color(hex: "0xF9E79F")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: .black.opacity(0.3), radius: 5, y: 3)
                            .overlay(
                                Capsule()
                                    .stroke(Color(hex: "0xF39C12"), lineWidth: 1.5)
                            )
                    )
                    
                    Spacer()
                    
                    // Rates Pill
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("+\(engine.formatNumber(engine.idleIncomePerSecond))/dtk")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(hex: "0x196F3D"))
                        
                        Text("+\(engine.formatNumber(engine.tapPower))/tap")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: "0xB9770E"))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.95))
                            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)
                
                // Combo Streak Pill
                if engine.comboCount > 2 {
                    HStack(spacing: 6) {
                        Text("🔥 COMBO x\(engine.comboCount)")
                            .font(.system(size: 13, weight: .heavy, design: .monospaced))
                            .foregroundStyle(Color(hex: "0xC0392B"))
                        
                        Text("BONUS \(String(format: "%.1f", engine.comboMultiplier))x")
                            .font(.system(size: 11, weight: .black))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(hex: "0xE74C3C"))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.92))
                    .clipShape(Capsule())
                    .shadow(radius: 3)
                    .padding(.top, 4)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Pickup Truck Stage (Sitting firmly on the sidewalk)
                ZStack(alignment: .bottom) {
                    SpriteView(name: akangCooking ? "truk_lengkap_masak" : "truk_lengkap_idle", contentMode: .fit)
                        .frame(height: 195)
                        .shadow(color: .black.opacity(0.45), radius: 8, y: 5)
                }
                .padding(.top, 4)
                
                // Pedestrian Customers Queue
                CustomerQueueView(engine: engine)
                    .frame(height: 48)
                
                Spacer(minLength: 10)
                
                // Interactive Giant Frying Pan Stage (Wajan on Kitchen Counter)
                GeometryReader { geo in
                    ZStack {
                        WajanView(engine: engine)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        
                        // Floating Numbers Overlay
                        ForEach(engine.floatingNumbers) { float in
                            Text(float.text)
                                .font(.system(size: 26, weight: .heavy, design: .rounded))
                                .foregroundStyle(float.color)
                                .shadow(color: .black.opacity(0.6), radius: 3, y: 2)
                                .position(x: float.offset.width, y: float.offset.height)
                                .opacity(float.opacity)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        engine.tapTahu(at: location)
                        triggerAkangCookingAnimation()
                    }
                }
                .frame(maxHeight: 285)
                
                Spacer(minLength: 12)
                
                // Bottom Action Dock: Pasar Upgrade Button
                HStack {
                    Button {
                        showShop = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "cart.fill")
                                .font(.system(size: 22, weight: .bold))
                            
                            Text("PASAR UPGRADE")
                                .font(.system(size: 19, weight: .black, design: .rounded))
                                .tracking(0.5)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(hex: "0xF5B041"),
                                    Color(hex: "0xF39C12"),
                                    Color(hex: "0xD35400")
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color(hex: "0xFED766"), lineWidth: 2)
                        )
                        .shadow(color: Color(hex: "0x78281F").opacity(0.55), radius: 8, y: 5)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 16)
            }
        }
        .sheet(isPresented: $showShop) {
            ShopView(engine: engine)
        }
        .alert("Tahu Laris Manis! 📦", isPresented: $engine.showOfflineAlert) {
            Button("Ambil Koin", role: .cancel) {}
        } message: {
            Text("Selama kamu offline, tahu bulat laku terjual Rp \(engine.formatNumber(engine.offlineEarnings))!")
        }
    }
    
    private func triggerAkangCookingAnimation() {
        akangCooking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            akangCooking = false
        }
    }
}
