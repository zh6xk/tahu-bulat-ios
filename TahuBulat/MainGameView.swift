import SwiftUI

struct MainGameView: View {
    @StateObject private var engine = GameEngine()
    @State private var showShop: Bool = false
    @State private var akangCooking: Bool = false
    
    var body: some View {
        ZStack {
            // Bright Bandung Street & Sky Background
            VStack(spacing: 0) {
                SpriteView(name: "bg_bandung", contentMode: .fill)
                    .frame(height: 260)
                    .clipped()
                
                // Street & Ground
                LinearGradient(
                    colors: [Color(hex: "0xDFDCDE"), Color(hex: "0xB2BABB")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            .ignoresSafeArea()
            
            VStack(spacing: 8) {
                // Top Header Stats Bar
                HStack(spacing: 12) {
                    // Coin Counter with Authentic Gold Coin Sprite
                    HStack(spacing: 8) {
                        SpriteView(name: "koin_emas", contentMode: .fit)
                            .frame(width: 34, height: 34)
                        
                        Text(engine.formatNumber(engine.coins))
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(Color(hex: "0x78281F"))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(hex: "0xF9E79F"))
                            .shadow(color: .black.opacity(0.18), radius: 5, y: 3)
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
                            .fill(Color.white.opacity(0.92))
                            .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
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
                    .background(Color.white.opacity(0.9))
                    .clipShape(Capsule())
                    .shadow(radius: 3)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Pickup Truck Stage (Mobil Pikap Tahu Bulat + Akang)
                ZStack {
                    // Bayangan Mobil
                    SpriteView(name: "bayangan_mobil", contentMode: .fit)
                        .frame(width: 280)
                        .offset(y: 40)
                    
                    // Mobil Pikap
                    SpriteView(name: "mobil_pickup", contentMode: .fit)
                        .frame(width: 270)
                    
                    // Tenda Mobil
                    SpriteView(name: "tenda_mobil", contentMode: .fit)
                        .frame(width: 175)
                        .offset(x: -28, y: -45)
                    
                    // Speaker Toa Blaring Jingle
                    SpriteView(name: "speaker_toa", contentMode: .fit)
                        .frame(width: 42)
                        .offset(x: -85, y: -72)
                    
                    // Plang Tahu Bulat
                    SpriteView(name: "plang_tahubulat", contentMode: .fit)
                        .frame(width: 76)
                        .offset(x: -28, y: -68)
                    
                    // Akang Penjual Tahu Bulat
                    SpriteView(name: akangCooking ? "akang_masak1" : "akang_idle", contentMode: .fit)
                        .frame(width: 68, height: 68)
                        .offset(x: -18, y: -12)
                }
                .frame(height: 155)
                
                // Customer Queue Along the Sidewalk
                CustomerQueueView(engine: engine)
                
                Spacer()
                
                // Giant Interactive Frying Pan (Wajan) Tap Area
                GeometryReader { geo in
                    ZStack {
                        WajanView(engine: engine)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        
                        // Floating Numbers Overlay
                        ForEach(engine.floatingNumbers) { float in
                            Text(float.text)
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                                .foregroundStyle(float.color)
                                .shadow(color: .black.opacity(0.4), radius: 2)
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
                .frame(height: 270)
                
                Spacer()
                
                // Bottom Control Dock: Pasar Upgrade
                HStack(spacing: 14) {
                    Button {
                        showShop = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "cart.fill")
                                .font(.system(size: 20))
                            Text("PASAR UPGRADE")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "0xF39C12"), Color(hex: "0xD35400")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: Color(hex: "0xD35400").opacity(0.45), radius: 8, y: 4)
                    }
                }
                .padding(.horizontal, 20)
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
