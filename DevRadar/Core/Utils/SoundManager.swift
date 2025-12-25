import Foundation
#if canImport(UIKit)
import UIKit
import AudioToolbox
#elseif os(macOS)
import AppKit
#endif

@MainActor
class SoundManager {
    static let shared = SoundManager()
    
    private init() {}
    
    func playRefreshSound() {
        #if canImport(UIKit)
        AudioServicesPlaySystemSound(1104) 
        #else
        NSSound.beep()
        #endif
    }
    
    func playSuccessSound() {
        #if canImport(UIKit)
        AudioServicesPlaySystemSound(1057) 
        #else
        NSSound.beep()
        #endif
    }
    
    func playErrorSound() {
        #if canImport(UIKit)
        AudioServicesPlaySystemSound(1053) 
        #else
        NSSound.beep()
        #endif
    }
}

