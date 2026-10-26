import SwiftUI

struct CustomerQueueView: View {
    @ObservedObject var engine: GameEngine
    
    var body: some View {
        ZStack {
            // Jalanan Aspal / Trotoar Depan Mobil Pikap
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "0x212F3D").opacity(0.85))
                .frame(height: 52)
                .overlay {
                    HStack(spacing: 12) {
                        ForEach(0..<8) { _ in
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 20, height: 4)
                        }
                    }
                }
            
            // Antrean Pembeli Berjalan
            HStack {
                ForEach(engine.customers) { customer in
                    Text(customer.emoji)
                        .font(.system(size: 32))
                        .offset(x: customer.xOffset)
                        .shadow(radius: 2)
                }
            }
        }
        .frame(height: 52)
        .padding(.horizontal, 16)
    }
}
