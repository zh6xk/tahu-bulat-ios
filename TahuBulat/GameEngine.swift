import SwiftUI
import Combine

enum UpgradeCategory: String, CaseIterable, Identifiable {
    case dapur = "Dapur"
    case bumbu = "Bumbu"
    case promosi = "Promosi"
    case cabang = "Cabang"
    
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .dapur: return "frying.pan.fill"
        case .bumbu: return "flame.fill"
        case .promosi: return "megaphone.fill"
        case .cabang: return "building.2.fill"
        }
    }
}

struct Upgrade: Identifiable, Codable {
    let id: String
    let name: String
    let categoryRaw: String
    let icon: String
    var level: Int
    let baseCost: Double
    let costMultiplier: Double
    let bonusPerLevel: Double
    let description: String
    
    var category: UpgradeCategory {
        UpgradeCategory(rawValue: categoryRaw) ?? .dapur
    }
    
    var cost: Double {
        baseCost * pow(costMultiplier, Double(level))
    }
}

struct FloatingNumber: Identifiable {
    let id = UUID()
    let text: String
    let color: Color
    var offset: CGSize
    var opacity: Double = 1.0
}

struct Customer: Identifiable {
    let id = UUID()
    let emoji: String
    var xOffset: CGFloat
}

@MainActor
final class GameEngine: ObservableObject {
    @Published var coins: Double = 50.0
    @Published var totalTaps: Int = 0
    @Published var comboCount: Int = 0
    @Published var comboMultiplier: Double = 1.0
    @Published var floatingNumbers: [FloatingNumber] = []
    @Published var customers: [Customer] = []
    @Published var offlineEarnings: Double = 0.0
    @Published var showOfflineAlert: Bool = false
    
    @Published var upgrades: [Upgrade] = [
        // Dapur
        Upgrade(id: "wajan_baja", name: "Wajan Baja Jumbo", categoryRaw: "Dapur", icon: "oval.fill", level: 1, baseCost: 30, costMultiplier: 1.15, bonusPerLevel: 2, description: "+2 koin per tap renyah"),
        Upgrade(id: "kompor_gas", name: "Kompor Gas Turbo", categoryRaw: "Dapur", icon: "flame.fill", level: 0, baseCost: 120, costMultiplier: 1.18, bonusPerLevel: 6, description: "+6 koin per tap"),
        Upgrade(id: "minyak_kelapa", name: "Minyak Kelapa Barokah", categoryRaw: "Dapur", icon: "drop.fill", level: 0, baseCost: 350, costMultiplier: 1.20, bonusPerLevel: 18, description: "+18 koin per tap"),
        
        // Bumbu
        Upgrade(id: "bumbu_balado", name: "Taburan Balado Pedas", categoryRaw: "Bumbu", icon: "sparkles", level: 0, baseCost: 75, costMultiplier: 1.16, bonusPerLevel: 3, description: "+3 koin per detik idle"),
        Upgrade(id: "keju_asin", name: "Keju Bubuk Gurih", categoryRaw: "Bumbu", icon: "circle.grid.cross.fill", level: 0, baseCost: 220, costMultiplier: 1.20, bonusPerLevel: 10, description: "+10 koin per detik idle"),
        Upgrade(id: "rumput_laut", name: "Nori Rumput Laut", categoryRaw: "Bumbu", icon: "leaf.fill", level: 0, baseCost: 600, costMultiplier: 1.22, bonusPerLevel: 32, description: "+32 koin per detik idle"),
        
        // Promosi
        Upgrade(id: "speaker_toa", name: "Speaker Toa 100 Watt", categoryRaw: "Promosi", icon: "speaker.wave.3.fill", level: 0, baseCost: 150, costMultiplier: 1.25, bonusPerLevel: 8, description: "+8 koin/dtk & manggil pembeli"),
        Upgrade(id: "banner_neon", name: "Spanduk Lampu Neon", categoryRaw: "Promosi", icon: "sun.max.fill", level: 0, baseCost: 450, costMultiplier: 1.24, bonusPerLevel: 25, description: "+25 koin/dtk"),
        Upgrade(id: "jingle_viral", name: "Jingle TikTok FYP", categoryRaw: "Promosi", icon: "music.note", level: 0, baseCost: 1200, costMultiplier: 1.28, bonusPerLevel: 75, description: "+75 koin/dtk"),
        
        // Cabang
        Upgrade(id: "pikap_modis", name: "Mobil Pikap Grand Max", categoryRaw: "Cabang", icon: "truck.pickup.fill", level: 0, baseCost: 2500, costMultiplier: 1.35, bonusPerLevel: 180, description: "+180 koin/dtk buka rute baru"),
        Upgrade(id: "cabang_stasiun", name: "Outlet Stasiun Kereta", categoryRaw: "Cabang", icon: "tram.fill", level: 0, baseCost: 8000, costMultiplier: 1.40, bonusPerLevel: 650, description: "+650 koin/dtk"),
        Upgrade(id: "cabang_mall", name: "Foodcourt Mall Mewah", categoryRaw: "Cabang", icon: "building.2.crop.circle.fill", level: 0, baseCost: 25000, costMultiplier: 1.45, bonusPerLevel: 2200, description: "+2200 koin/dtk")
    ]
    
    private var timerCancellable: AnyCancellable?
    private var comboResetCancellable: AnyCancellable?
    private let customerEmojis = ["🏃‍♂️", "👧", "🧔", "👵", "👮‍♂️", "🧑‍🦰", "🛵", "🧍‍♀️"]
    
    var tapPower: Double {
        var base: Double = 1.0
        for item in upgrades where item.category == .dapur {
            base += Double(item.level) * item.bonusPerLevel
        }
        return base * comboMultiplier
    }
    
    var idleIncomePerSecond: Double {
        var income: Double = 0.0
        for item in upgrades where item.category != .dapur {
            income += Double(item.level) * item.bonusPerLevel
        }
        return income
    }
    
    init() {
        loadData()
        startIdleLoop()
        spawnCustomerLoop()
    }
    
    func tapTahu(at location: CGPoint) {
        let earned = tapPower
        coins += earned
        totalTaps += 1
        
        // Combo Meter
        comboCount += 1
        updateCombo()
        
        // Sound & Haptic
        SoundManager.shared.playPop()
        
        // Spawn Floating Number
        spawnFloatingNumber(text: "+\(formatNumber(earned))", at: location, isCrit: comboMultiplier > 1.5)
        
        // Save
        saveData()
    }
    
    private func updateCombo() {
        if comboCount >= 30 {
            comboMultiplier = 3.0
        } else if comboCount >= 15 {
            comboMultiplier = 2.0
        } else if comboCount >= 5 {
            comboMultiplier = 1.5
        } else {
            comboMultiplier = 1.0
        }
        
        // Reset combo timer (kalau ga tap selama 1.2 detik, combo reset)
        comboResetCancellable?.cancel()
        comboResetCancellable = Just(())
            .delay(for: .seconds(1.2), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                withAnimation(.easeOut(duration: 0.3)) {
                    self.comboCount = 0
                    self.comboMultiplier = 1.0
                }
            }
    }
    
    private func spawnFloatingNumber(text: String, at location: CGPoint, isCrit: Bool) {
        let randomX = CGFloat.random(in: -30...30)
        let color: Color = isCrit ? Color(hex: "0xFF4500") : Color(hex: "0xFFA500")
        var float = FloatingNumber(text: text, color: color, offset: CGSize(width: location.x + randomX, height: location.y))
        floatingNumbers.append(float)
        
        let id = float.id
        withAnimation(.easeOut(duration: 0.75)) {
            if let idx = self.floatingNumbers.firstIndex(where: { $0.id == id }) {
                self.floatingNumbers[idx].offset.height -= 70
                self.floatingNumbers[idx].opacity = 0.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.floatingNumbers.removeAll { $0.id == id }
        }
    }
    
    func buyUpgrade(id: String) {
        guard let index = upgrades.firstIndex(where: { $0.id == id }) else { return }
        let cost = upgrades[index].cost
        if coins >= cost {
            coins -= cost
            upgrades[index].level += 1
            SoundManager.shared.playUpgrade()
            saveData()
        }
    }
    
    private func startIdleLoop() {
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                let income = self.idleIncomePerSecond
                if income > 0 {
                    self.coins += income
                    self.saveData()
                }
            }
    }
    
    private func spawnCustomerLoop() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let promoLevel = self.upgrades.filter { $0.category == .promosi }.map { $0.level }.reduce(0, +)
            if self.customers.count < (3 + min(promoLevel, 6)) {
                let emoji = self.customerEmojis.randomElement() ?? "🏃‍♂️"
                let newCustomer = Customer(emoji: emoji, xOffset: 200)
                self.customers.append(newCustomer)
                
                let id = newCustomer.id
                withAnimation(.easeInOut(duration: 2.5)) {
                    if let idx = self.customers.firstIndex(where: { $0.id == id }) {
                        self.customers[idx].xOffset = -200
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                    self.customers.removeAll { $0.id == id }
                }
            }
        }
    }
    
    // Persistence
    private func saveData() {
        UserDefaults.standard.set(coins, forKey: "tb_coins")
        UserDefaults.standard.set(totalTaps, forKey: "tb_taps")
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "tb_last_active")
        if let encoded = try? JSONEncoder().encode(upgrades) {
            UserDefaults.standard.set(encoded, forKey: "tb_upgrades")
        }
    }
    
    private func loadData() {
        if let savedCoins = UserDefaults.standard.value(forKey: "tb_coins") as? Double {
            self.coins = savedCoins
        }
        if let savedTaps = UserDefaults.standard.value(forKey: "tb_taps") as? Int {
            self.totalTaps = savedTaps
        }
        if let savedData = UserDefaults.standard.data(forKey: "tb_upgrades"),
           let decoded = try? JSONDecoder().decode([Upgrade].self, from: savedData) {
            self.upgrades = decoded
        }
        
        // Calculate Offline Earnings
        if let lastActive = UserDefaults.standard.value(forKey: "tb_last_active") as? Double {
            let elapsed = Date().timeIntervalSince1970 - lastActive
            let idle = idleIncomePerSecond
            if elapsed > 10 && idle > 0 {
                let maxOfflineSeconds: Double = 8 * 3600 // max 8 jam
                let cappedElapsed = min(elapsed, maxOfflineSeconds)
                let earned = cappedElapsed * idle
                self.offlineEarnings = earned
                self.coins += earned
                self.showOfflineAlert = true
            }
        }
    }
    
    func formatNumber(_ num: Double) -> String {
        if num >= 1_000_000_000 {
            return String(format: "%.2f B", num / 1_000_000_000)
        } else if num >= 1_000_000 {
            return String(format: "%.2f M", num / 1_000_000)
        } else if num >= 1_000 {
            return String(format: "%.1f K", num / 1_000)
        } else {
            return String(format: "%.0f", num)
        }
    }
}
