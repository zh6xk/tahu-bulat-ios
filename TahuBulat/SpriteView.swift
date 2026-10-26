import SwiftUI
import UIKit

struct SpriteView: View {
    let name: String
    var contentMode: ContentMode = .fit
    
    var body: some View {
        if let uiImage = UIImage(named: name) ?? loadFromBundle(name: name) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            Rectangle()
                .fill(Color.clear)
        }
    }
    
    private func loadFromBundle(name: String) -> UIImage? {
        let exts = ["png", "jpg", "jpeg"]
        for ext in exts {
            if let path = Bundle.main.path(forResource: name, ofType: ext, inDirectory: "Resources/Sprites") ?? Bundle.main.path(forResource: name, ofType: ext) {
                if let img = UIImage(contentsOfFile: path) {
                    return img
                }
            }
        }
        return nil
    }
}
