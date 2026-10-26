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
                Color(hex: "0xF8F9F9").ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Category Picker Tabs
                    HStack(spacing: 8) {
                        ForEach(UpgradeCategory.allCases) { cat in
                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    selectedCategory = cat
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: cat.icon)
                                    Text(cat.rawValue)
                                        .font(.system(size: 13, weight: .bold))
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 14)
                                .background(selectedCategory == cat ? Color(hex: "0xE67E22") : Color(hex: "0xEAEDED"))
                                .foregroundStyle(selectedCategory == cat ? .white : Color(hex: "0x5D6D7E"))
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 6) {
                        SpriteView(name: "koin_emas", contentMode: .fit)
                            .frame(width: 22, height: 22)
                        Text(engine.formatNumber(engine.coins))
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(hex: "0x78281F"))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color(hex: "0x95A5A6"))
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
                    .fill(Color(hex: "0xFDEBD0"))
                    .frame(width: 50, height: 50)
                Image(systemName: item.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(Color(hex: "0xD35400"))
            }
            
            // Description & Level
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(item.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color(hex: "0x2C3E50"))
                    
                    Text("Lv.\(item.level)")
                        .font(.system(size: 11, weight: .heavy))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: "0xD4EFDF"))
                        .foregroundStyle(Color(hex: "0x1E8449"))
                        .clipShape(Capsule())
                }
                
                Text(item.description)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "0x7F8C8D"))
                    .lineLimit(1)
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
                    : LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)], startPoint: .top, endPoint: .bottom)
                )
                .foregroundStyle(canAfford ? .white : Color(hex: "0x7F8C8D"))
                .clipShape(Capsule())
                .shadow(color: canAfford ? Color(hex: "0xD35400").opacity(0.3) : .clear, radius: 4, y: 2)
            }
            .disabled(!canAfford)
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)
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
