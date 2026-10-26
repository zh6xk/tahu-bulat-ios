import AVFoundation
import AudioToolbox
import UIKit

@MainActor
final class SoundManager {
    static let shared = SoundManager()
    
    private init() {}
    
    func playPop() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        AudioServicesPlaySystemSound(1104) // iOS keyboard pop
    }
    
    func playCash() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        AudioServicesPlaySystemSound(1057) // iOS pin audio
    }
    
    func playUpgrade() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        AudioServicesPlaySystemSound(1025) // iOS chime
    }
    
    func playFrenzy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        AudioServicesPlaySystemSound(1001) // iOS mail sent swoosh
    }
}
