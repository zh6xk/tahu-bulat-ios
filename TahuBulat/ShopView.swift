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
                Color(hex: "0x12151A").ignoresSafeArea()
                
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
                                .padding(.horizontal, 12)
                                .background(selectedCategory == cat ? Color(hex: "0xE67E22") : Color.white.opacity(0.08))
                                .foregroundStyle(selectedCategory == cat ? .white : .secondary)
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    
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
            .navigationTitle("Pasar & Upgrade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 6) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundStyle(Color(hex: "0xF39C12"))
                        Text(engine.formatNumber(engine.coins))
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.secondary)
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
                    .fill(Color.white.opacity(0.07))
                    .frame(width: 50, height: 50)
                Image(systemName: item.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(Color(hex: "0xF39C12"))
            }
            
            // Description & Level
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(item.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("Lv.\(item.level)")
                        .font(.system(size: 11, weight: .heavy))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: "0x27AE60").opacity(0.3))
                        .foregroundStyle(Color(hex: "0x2ECC71"))
                        .clipShape(Capsule())
                }
                
                Text(item.description)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
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
                .foregroundStyle(canAfford ? .white : .secondary)
                .clipShape(Capsule())
                .shadow(color: canAfford ? Color(hex: "0xD35400").opacity(0.4) : .clear, radius: 6, y: 3)
            }
            .disabled(!canAfford)
        }
        .padding(12)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
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
