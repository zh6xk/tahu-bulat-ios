import SwiftUI

struct WalkingCustomerView: View {
    let customer: Customer
    @State private var posX: CGFloat = 220
    
    var body: some View {
        VStack(spacing: 2) {
            Text("Beli Tahu! 😋")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.black.opacity(0.7))
                .clipShape(Capsule())
            
            Text(customer.emoji)
                .font(.system(size: 38))
        }
        .offset(x: posX)
        .onAppear {
            withAnimation(.linear(duration: 3.2)) {
                posX = -220
            }
        }
    }
}

struct CustomerQueueView: View {
    @ObservedObject var engine: GameEngine
    
    var body: some View {
        ZStack {
            // Sidewalk Bandung
            SpriteView(name: "bg_jalan", contentMode: .fill)
                .frame(height: 48)
                .clipped()
                .overlay {
                    Color.black.opacity(0.15)
                }
            
            // Antrean Pembeli Berjalan Melewati Depan Truk
            ForEach(engine.customers) { customer in
                WalkingCustomerView(customer: customer)
            }
        }
        .frame(height: 60)
        .clipped()
    }
}
