import SwiftUI

struct CustomerQueueView: View {
    @ObservedObject var engine: GameEngine
    
    var body: some View {
        ZStack {
            // Sidewalk / Trotoar Bandung
            SpriteView(name: "bg_jalan", contentMode: .fill)
                .frame(height: 58)
                .clipped()
                .overlay {
                    Color.black.opacity(0.12)
                }
            
            // Antrean Pembeli Berjalan Mendekat ke Mobil Pikap
            HStack(spacing: 0) {
                Spacer()
                ForEach(engine.customers) { customer in
                    VStack(spacing: 0) {
                        // Dialog Balon Beli
                        Text("Beli Tahu! 😋")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.65))
                            .clipShape(Capsule())
                        
                        SpriteView(name: "customer_walk1", contentMode: .fit)
                            .frame(width: 44, height: 62)
                    }
                    .offset(x: customer.xOffset)
                    .shadow(radius: 2)
                }
            }
            .padding(.horizontal, 10)
        }
        .frame(height: 80)
    }
}
