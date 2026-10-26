import AVFoundation
import AudioToolbox
import UIKit

@MainActor
final class SoundManager {
    static let shared = SoundManager()
    
    private var bgmPlayer: AVAudioPlayer?
    private var sfxPlayers: [String: AVAudioPlayer] = [:]
    private var voiceIndex: Int = 0
    private let voiceSequence = [
        "voice_tahu",
        "voice_bulat",
        "voice_digoreng",
        "voice_dadakan",
        "voice_enak"
    ]
    
    private init() {
        configureAudioSession()
        startBGM()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioSession setup error: \(error)")
        }
    }
    
    func startBGM() {
        let url = Bundle.main.url(forResource: "bgm_tahubulat", withExtension: "mp3", subdirectory: "Resources/Audio") ?? Bundle.main.url(forResource: "bgm_tahubulat", withExtension: "mp3")
        guard let url = url else { return }
        do {
            bgmPlayer = try AVAudioPlayer(contentsOf: url)
            bgmPlayer?.numberOfLoops = -1
            bgmPlayer?.volume = 0.5
            bgmPlayer?.prepareToPlay()
            bgmPlayer?.play()
        } catch {
            print("BGM play error: \(error)")
        }
    }
    
    func playPop() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        playVoiceSequence()
    }
    
    func playVoiceSequence() {
        let soundName = voiceSequence[voiceIndex % voiceSequence.count]
        voiceIndex += 1
        playSound(soundName)
    }
    
    func playCash() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        playSound("sfx_coin", fallbackSystemSound: 1057)
    }
    
    func playCook() {
        playSound("sfx_cook", fallbackSystemSound: 1104)
    }
    
    func playUpgrade() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        playSound("sfx_click", fallbackSystemSound: 1025)
    }
    
    func playFrenzy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        AudioServicesPlaySystemSound(1001)
    }
    
    private func playSound(_ name: String, fallbackSystemSound: SystemSoundID? = nil) {
        if let player = sfxPlayers[name] {
            player.currentTime = 0
            player.play()
            return
        }
        
        let url = Bundle.main.url(forResource: name, withExtension: "mp3", subdirectory: "Resources/Audio") ?? Bundle.main.url(forResource: name, withExtension: "mp3")
        
        if let url = url, let player = try? AVAudioPlayer(contentsOf: url) {
            player.prepareToPlay()
            player.play()
            sfxPlayers[name] = player
        } else if let fallback = fallbackSystemSound {
            AudioServicesPlaySystemSound(fallback)
        }
    }
}
