import SwiftUI

struct ShopView: View {
    @ObservedObject var engine: GameEngine
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: UpgradeCategory = .dapur
    
    var filteredUpgrades: [Upgrade] {
        engine.upgrades.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0x161B22").ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Category Picker Tabs (Horizontal Scrollable, Never Wrapping)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(UpgradeCategory.allCases) { cat in
                                Button {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                        selectedCategory = cat
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: cat.icon)
                                        Text(cat.rawValue)
                                            .font(.system(size: 14, weight: .bold))
                                            .lineLimit(1)
                                            .fixedSize(horizontal: true, vertical: false)
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 16)
                                    .background(
                                        selectedCategory == cat
                                        ? LinearGradient(colors: [Color(hex: "0xE67E22"), Color(hex: "0xD35400")], startPoint: .top, endPoint: .bottom)
                                        : LinearGradient(colors: [Color(hex: "0x21262D"), Color(hex: "0x21262D")], startPoint: .top, endPoint: .bottom)
                                    )
                                    .foregroundStyle(selectedCategory == cat ? Color.white : Color(hex: "0x8B949E"))
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(selectedCategory == cat ? Color.clear : Color(hex: "0x30363D"), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 14)
                    
                    // List of Upgrades
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredUpgrades) { item in
                                UpgradeRow(item: item, coins: engine.coins) {
                                    engine.buyUpgrade(id: item.id)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Pasar Upgrade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "0x161B22"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 6) {
                        SpriteView(name: "koin_emas", contentMode: .fit)
                            .frame(width: 22, height: 22)
                        Text(engine.formatNumber(engine.coins))
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(hex: "0xF1C40F"))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color(hex: "0x8B949E"))
                    }
                }
            }
        }
    }
}

struct UpgradeRow: View {
    let item: Upgrade
    let coins: Double
    let onBuy: () -> Void
    
    var canAfford: Bool {
        coins >= item.cost
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "0xE67E22").opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: item.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(Color(hex: "0xE67E22"))
            }
            
            // Description & Level
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(item.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.white)
                    
                    Text("Lv.\(item.level)")
                        .font(.system(size: 11, weight: .heavy))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Color(hex: "0x238636").opacity(0.35))
                        .foregroundStyle(Color(hex: "0x3FB950"))
                        .clipShape(Capsule())
                }
                
                Text(item.description)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "0x8B949E"))
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Buy Button
            Button(action: onBuy) {
                HStack(spacing: 4) {
                    Text("💰")
                        .font(.system(size: 12))
                    Text(formatShort(item.cost))
                        .font(.system(size: 14, weight: .black, design: .rounded))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    canAfford
                    ? LinearGradient(colors: [Color(hex: "0xE67E22"), Color(hex: "0xD35400")], startPoint: .top, endPoint: .bottom)
                    : LinearGradient(colors: [Color(hex: "0x30363D"), Color(hex: "0x21262D")], startPoint: .top, endPoint: .bottom)
                )
                .foregroundStyle(canAfford ? Color.white : Color(hex: "0x6E7681"))
                .clipShape(Capsule())
                .shadow(color: canAfford ? Color(hex: "0xD35400").opacity(0.4) : Color.clear, radius: 4, y: 2)
            }
            .disabled(!canAfford)
        }
        .padding(12)
        .background(Color(hex: "0x21262D"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "0x30363D"), lineWidth: 1)
        )
    }
    
    private func formatShort(_ num: Double) -> String {
        if num >= 1_000_000_000 {
            return String(format: "%.1fB", num / 1_000_000_000)
        } else if num >= 1_000_000 {
            return String(format: "%.1fM", num / 1_000_000)
        } else if num >= 1_000 {
            return String(format: "%.1fK", num / 1_000)
        } else {
            return String(format: "%.0f", num)
        }
    }
}
