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
                .background(Color.black.opacity(0.75))
                .clipShape(Capsule())
            
            Text(customer.emoji)
                .font(.system(size: 36))
                .shadow(color: .black.opacity(0.3), radius: 2, y: 2)
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
            // Antrean Pembeli Berjalan Melewati Depan Truk (Transparent overlay)
            ForEach(engine.customers) { customer in
                WalkingCustomerView(customer: customer)
            }
        }
        .frame(height: 52)
        .clipped()
    }
}
