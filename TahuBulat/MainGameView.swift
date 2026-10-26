import SwiftUI

struct MainGameView: View {
    @StateObject private var engine = GameEngine()
    @State private var showShop: Bool = false
    @State private var wajanRef = WajanView(engine: GameEngine())
    
    var body: some View {
        ZStack {
            // Background Theme
            LinearGradient(
                colors: [Color(hex: "0x1C130E"), Color(hex: "0x0B0806")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Top Header Stats
                VStack(spacing: 6) {
                    HStack(spacing: 8) {
                        Text("💰")
                            .font(.system(size: 32))
                        Text(engine.formatNumber(engine.coins))
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "0xF9E79F"), Color(hex: "0xF39C12")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: Color(hex: "0xF39C12").opacity(0.3), radius: 8, y: 3)
                    }
                    
                    HStack(spacing: 14) {
                        Label("+\(engine.formatNumber(engine.idleIncomePerSecond))/s", systemImage: "clock.arrow.circlepath")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.secondary)
                        
                        Text("•")
                            .foregroundStyle(.secondary)
                        
                        Label("+\(engine.formatNumber(engine.tapPower))/tap", systemImage: "hand.tap")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color(hex: "0xE67E22"))
                    }
                }
                .padding(.top, 16)
                
                // Combo Streak Indicator
                if engine.comboCount > 2 {
                    HStack(spacing: 8) {
                        Text("🔥 COMBO x\(engine.comboCount)")
                            .font(.system(size: 13, weight: .heavy, design: .monospaced))
                            .foregroundStyle(Color(hex: "0xFF4500"))
                        
                        Text("BONUS \(String(format: "%.1f", engine.comboMultiplier))x")
                            .font(.system(size: 11, weight: .black))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(hex: "0xFF4500"))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Spacer().frame(height: 24)
                }
                
                Spacer()
                
                // Central Frying Pan (Wajan) Tap Area
                GeometryReader { geo in
                    ZStack {
                        WajanView(engine: engine)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        
                        // Floating Numbers Overlay
                        ForEach(engine.floatingNumbers) { float in
                            Text(float.text)
                                .font(.system(size: 22, weight: .heavy, design: .rounded))
                                .foregroundStyle(float.color)
                                .shadow(color: .black.opacity(0.5), radius: 2)
                                .position(x: float.offset.width, y: float.offset.height)
                                .opacity(float.opacity)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        engine.tapTahu(at: location)
                    }
                }
                .frame(height: 310)
                
                Spacer()
                
                // Antrean Pembeli Animasi
                CustomerQueueView(engine: engine)
                
                // Bottom Control Dock
                HStack(spacing: 14) {
                    Button {
                        showShop = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "cart.fill")
                                .font(.system(size: 18))
                            Text("PASAR UPGRADE")
                                .font(.system(size: 16, weight: .heavy, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "0xE67E22"), Color(hex: "0xD35400")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: Color(hex: "0xD35400").opacity(0.5), radius: 10, y: 5)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
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
}
