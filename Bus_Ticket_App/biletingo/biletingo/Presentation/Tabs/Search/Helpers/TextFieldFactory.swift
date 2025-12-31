//
//  TextFieldFactory.swift
//  biletingo
//
//  Created by Gokhan on 15.09.2025.
//

import UIKit

enum TextFieldFactory {
    
    static func make(
        placeholder: String,
        contentType: UITextContentType? = nil,
        keyboard: UIKeyboardType = .default,
        returnKey: UIReturnKeyType = .default,
        delegate: UITextFieldDelegate? = nil
    ) -> UITextField {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .roundedRect
        tf.placeholder = placeholder
        tf.textContentType = contentType
        tf.keyboardType = keyboard
        tf.returnKeyType = returnKey
        tf.autocorrectionType = .no
        tf.clearButtonMode = .whileEditing
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        tf.delegate = delegate
        return tf
    }
}

extension UIView {
    static func separator(height: CGFloat = 1) -> UIView {
        let v = UIView()
        v.backgroundColor = .separator
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: height).isActive = true
        return v
    }
}
