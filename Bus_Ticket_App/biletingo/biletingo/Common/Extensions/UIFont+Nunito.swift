//
//  UIFont+Nunito.swift
//  biletingo
//
//  Created by Gokhan on 6.09.2025.
//

import UIKit

extension UIFont {
    
    enum NunitoWeight: String {
        case regular = "Regular"
        case bold = "Bold"
        case semiBold = "SemiBold"
        case light = "Light"
        case italic = "Italic"
    }
    
    static func nunito(_ weight: NunitoWeight = .regular, size: CGFloat) -> UIFont {
        return UIFont(name: "Nunito-\(weight.rawValue)", size: size)
            ?? UIFont.systemFont(ofSize: size)
    }
}
