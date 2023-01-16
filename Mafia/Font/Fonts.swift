import UIKit

extension UIFont {
    static func podkovaFont(size: CGFloat, type: PodkovaFamily) -> UIFont {
        guard let customFont = UIFont(name: type.fontName, size: size) else {
            return .systemFont(ofSize: size)
        }
        return customFont
    }
    
    static func podkovaFont(type: PodkovaFamily) -> UIFont {
        guard let customFont = UIFont(name: type.fontName, size: UIFont.labelFontSize) else {
            return .systemFont(ofSize: UIFont.labelFontSize)
        }
        return customFont
    }
    
    enum PodkovaFamily {
        case regular
        case semiBold
    }
}

extension UIFont.PodkovaFamily {
    var fontName: String {
        switch self{
        case .regular:
            return "Podkova-Regular"
        case .semiBold:
            return "Podkova-SemiBold"
        }
    }
}
