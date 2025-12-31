//
//  MakeFieldRow.swift
//  biletingo
//
//  Created by Gokhan on 15.09.2025.
//

import UIKit

func makeFieldRow(title: String, rightView: UIView) -> UIStackView {
    
    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
    titleLabel.textColor = .secondaryLabel
    titleLabel.setContentHuggingPriority(.required, for: .horizontal)
    titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

    rightView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    rightView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    let h = UIStackView(arrangedSubviews: [titleLabel, rightView])
    h.axis = .horizontal
    h.alignment = .center
    h.spacing = 8
    h.distribution = .fill
    h.translatesAutoresizingMaskIntoConstraints = false
    return h
}

func makeSeparator() -> UIView {
    let v = UIView()
    v.backgroundColor = .separator
    v.translatesAutoresizingMaskIntoConstraints = false
    v.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale).isActive = true
    v.setContentCompressionResistancePriority(.required, for: .vertical)
    return v
}
